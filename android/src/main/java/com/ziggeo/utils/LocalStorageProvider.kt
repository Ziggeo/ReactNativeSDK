package com.ziggeo.utils

import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Point
import android.os.Build
import android.os.CancellationSignal
import android.os.Environment
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Root
import android.provider.DocumentsProvider
import android.util.Log
import android.webkit.MimeTypeMap
import androidx.annotation.RequiresApi
import com.ziggeo.R
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException

/**
 * Created by alex on 10/2/2017.
 */
@RequiresApi(api = Build.VERSION_CODES.KITKAT)
class LocalStorageProvider : DocumentsProvider() {
    @Throws(FileNotFoundException::class)
    override fun queryRoots(projection: Array<String>): Cursor {
        // Create a cursor with either the requested fields, or the default
        // projection if "projection" is null.
        val result = MatrixCursor(projection ?: DEFAULT_ROOT_PROJECTION)
        // Add Home directory
        val homeDir = Environment.getExternalStorageDirectory()
        val row = result.newRow()
        // These columns are required
        row.add(Root.COLUMN_ROOT_ID, homeDir.absolutePath)
        row.add(Root.COLUMN_DOCUMENT_ID, homeDir.absolutePath)
        row.add(Root.COLUMN_TITLE, context!!.getString(R.string.internal_storage))
        row.add(Root.COLUMN_FLAGS, Root.FLAG_LOCAL_ONLY or Root.FLAG_SUPPORTS_CREATE)
        row.add(Root.COLUMN_ICON, R.drawable.ic_provider)
        // These columns are optional
        row.add(Root.COLUMN_AVAILABLE_BYTES, homeDir.freeSpace)
        // Root.COLUMN_MIME_TYPE is another optional column and useful if you
        // have multiple roots with different
        // types of mime types (roots that don't match the requested mime type
        // are automatically hidden)
        return result
    }

    @Throws(FileNotFoundException::class)
    override fun createDocument(parentDocumentId: String, mimeType: String,
                                displayName: String): String? {
        val newFile = File(parentDocumentId, displayName)
        try {
            newFile.createNewFile()
            return newFile.absolutePath
        } catch (e: IOException) {
            Log.e(LocalStorageProvider::class.java.simpleName, "Error creating new file $newFile")
        }
        return null
    }

    @Throws(FileNotFoundException::class)
    override fun openDocumentThumbnail(documentId: String, sizeHint: Point,
                                       signal: CancellationSignal): AssetFileDescriptor? {
        // Assume documentId points to an image file. Build a thumbnail no
        // larger than twice the sizeHint
        val options = BitmapFactory.Options()
        options.inJustDecodeBounds = true
        BitmapFactory.decodeFile(documentId, options)
        val targetHeight = 2 * sizeHint.y
        val targetWidth = 2 * sizeHint.x
        val height = options.outHeight
        val width = options.outWidth
        options.inSampleSize = 1
        if (height > targetHeight || width > targetWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            // Calculate the largest inSampleSize value that is a power of 2 and
            // keeps both
            // height and width larger than the requested height and width.
            while (halfHeight / options.inSampleSize > targetHeight
                    || halfWidth / options.inSampleSize > targetWidth) {
                options.inSampleSize *= 2
            }
        }
        options.inJustDecodeBounds = false
        val bitmap = BitmapFactory.decodeFile(documentId, options)
        // Write out the thumbnail to a temporary file
        var tempFile: File? = null
        var out: FileOutputStream? = null
        try {
            tempFile = File.createTempFile("thumbnail", null, context!!.cacheDir)
            out = FileOutputStream(tempFile)
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, out)
        } catch (e: IOException) {
            Log.e(LocalStorageProvider::class.java.simpleName, "Error writing thumbnail", e)
            return null
        } finally {
            if (out != null) try {
                out.close()
            } catch (e: IOException) {
                Log.e(LocalStorageProvider::class.java.simpleName, "Error closing thumbnail", e)
            }
        }
        // It appears the Storage Framework UI caches these results quite
        // aggressively so there is little reason to
        // write your own caching layer beyond what you need to return a single
        // AssetFileDescriptor
        return AssetFileDescriptor(ParcelFileDescriptor.open(tempFile,
                ParcelFileDescriptor.MODE_READ_ONLY), 0,
                AssetFileDescriptor.UNKNOWN_LENGTH)
    }

    @Throws(FileNotFoundException::class)
    override fun queryChildDocuments(parentDocumentId: String, projection: Array<String>,
                                     sortOrder: String): Cursor {
        // Create a cursor with either the requested fields, or the default
        // projection if "projection" is null.
        val result = MatrixCursor(projection ?: DEFAULT_DOCUMENT_PROJECTION)
        val parent = File(parentDocumentId)
        for (file in parent.listFiles()) {
            // Don't show hidden files/folders
            if (!file.name.startsWith(".")) {
                // Adds the file's display name, MIME type, size, and so on.
                includeFile(result, file)
            }
        }
        return result
    }

    @Throws(FileNotFoundException::class)
    override fun queryDocument(documentId: String, projection: Array<String>): Cursor {
        // Create a cursor with either the requested fields, or the default
        // projection if "projection" is null.
        val result = MatrixCursor(projection ?: DEFAULT_DOCUMENT_PROJECTION)
        includeFile(result, File(documentId))
        return result
    }

    @Throws(FileNotFoundException::class)
    private fun includeFile(result: MatrixCursor, file: File) {
        val row = result.newRow()
        // These columns are required
        row.add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, file.absolutePath)
        row.add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, file.name)
        val mimeType = getDocumentType(file.absolutePath)
        row.add(DocumentsContract.Document.COLUMN_MIME_TYPE, mimeType)
        var flags = if (file.canWrite()) DocumentsContract.Document.FLAG_SUPPORTS_DELETE or DocumentsContract.Document.FLAG_SUPPORTS_WRITE else 0
        // We only show thumbnails for image files - expect a call to
        // openDocumentThumbnail for each file that has
        // this flag set
        if (mimeType.startsWith("image/")) flags = flags or DocumentsContract.Document.FLAG_SUPPORTS_THUMBNAIL
        row.add(DocumentsContract.Document.COLUMN_FLAGS, flags)
        // COLUMN_SIZE is required, but can be null
        row.add(DocumentsContract.Document.COLUMN_SIZE, file.length())
        // These columns are optional
        row.add(DocumentsContract.Document.COLUMN_LAST_MODIFIED, file.lastModified())
        // Document.COLUMN_ICON can be a resource id identifying a custom icon.
        // The system provides default icons
        // based on mime type
        // Document.COLUMN_SUMMARY is optional additional information about the
        // file
    }

    @Throws(FileNotFoundException::class)
    override fun getDocumentType(documentId: String): String {
        val file = File(documentId)
        if (file.isDirectory) return DocumentsContract.Document.MIME_TYPE_DIR
        // From FileProvider.getType(Uri)
        val lastDot = file.name.lastIndexOf('.')
        if (lastDot >= 0) {
            val extension = file.name.substring(lastDot + 1)
            val mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            if (mime != null) {
                return mime
            }
        }
        return "application/octet-stream"
    }

    @Throws(FileNotFoundException::class)
    override fun deleteDocument(documentId: String) {
        File(documentId).delete()
    }

    @Throws(FileNotFoundException::class)
    override fun openDocument(documentId: String, mode: String,
                              signal: CancellationSignal?): ParcelFileDescriptor {
        val file = File(documentId)
        val isWrite = mode.indexOf('w') != -1
        return if (isWrite) {
            ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_WRITE)
        } else {
            ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        }
    }

    override fun onCreate(): Boolean {
        return true
    }

    companion object {
        const val AUTHORITY = "com.ianhanniballake.localstorage.documents"

        /**
         * Default root projection: everything but Root.COLUMN_MIME_TYPES
         */
        private val DEFAULT_ROOT_PROJECTION = arrayOf(
                Root.COLUMN_ROOT_ID,
                Root.COLUMN_FLAGS, Root.COLUMN_TITLE, Root.COLUMN_DOCUMENT_ID, Root.COLUMN_ICON,
                Root.COLUMN_AVAILABLE_BYTES
        )

        /**
         * Default document projection: everything but Document.COLUMN_ICON and
         * Document.COLUMN_SUMMARY
         */
        private val DEFAULT_DOCUMENT_PROJECTION = arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_FLAGS, DocumentsContract.Document.COLUMN_MIME_TYPE,
                DocumentsContract.Document.COLUMN_SIZE,
                DocumentsContract.Document.COLUMN_LAST_MODIFIED
        )
    }
}