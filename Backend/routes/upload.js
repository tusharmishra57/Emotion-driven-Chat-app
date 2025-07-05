const express = require('express');
const multer = require('multer');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs').promises;
const { auth } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = process.env.ALLOWED_FILE_TYPES?.split(',') || [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
      'video/mp4',
      'video/webm',
      'audio/mp3',
      'audio/wav',
      'audio/ogg'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`Invalid file type. Allowed types: ${allowedTypes.join(', ')}`), false);
    }
  }
});

// Ensure upload directory exists
const ensureUploadDir = async (dir) => {
  try {
    await fs.access(dir);
  } catch {
    await fs.mkdir(dir, { recursive: true });
  }
};

// @route   POST /api/upload/avatar
// @desc    Upload user avatar
// @access  Private
router.post('/avatar', auth, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Avatar file is required'
      });
    }

    // Validate file type
    if (!req.file.mimetype.startsWith('image/')) {
      return res.status(400).json({
        success: false,
        message: 'Avatar must be an image file'
      });
    }

    const uploadDir = path.join(__dirname, '../uploads/avatars');
    await ensureUploadDir(uploadDir);

    // Process image with Sharp
    const filename = `${req.user._id}_${uuidv4()}.jpg`;
    const filepath = path.join(uploadDir, filename);

    await sharp(req.file.buffer)
      .resize(200, 200, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toFile(filepath);

    // Update user avatar
    const avatarUrl = `/uploads/avatars/${filename}`;
    req.user.avatar = avatarUrl;
    await req.user.save();

    res.json({
      success: true,
      message: 'Avatar uploaded successfully',
      data: {
        avatarUrl,
        filename
      }
    });

  } catch (error) {
    console.error('Avatar upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during avatar upload'
    });
  }
});

// @route   POST /api/upload/image
// @desc    Upload general image
// @access  Private
router.post('/image', auth, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Image file is required'
      });
    }

    // Validate file type
    if (!req.file.mimetype.startsWith('image/')) {
      return res.status(400).json({
        success: false,
        message: 'File must be an image'
      });
    }

    const uploadDir = path.join(__dirname, '../uploads/images');
    await ensureUploadDir(uploadDir);

    // Process image with Sharp
    const filename = `${uuidv4()}.jpg`;
    const filepath = path.join(uploadDir, filename);

    const metadata = await sharp(req.file.buffer)
      .resize(1024, 1024, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 85 })
      .toFile(filepath);

    const imageUrl = `/uploads/images/${filename}`;

    res.json({
      success: true,
      message: 'Image uploaded successfully',
      data: {
        url: imageUrl,
        filename,
        size: metadata.size,
        width: metadata.width,
        height: metadata.height,
        format: metadata.format
      }
    });

  } catch (error) {
    console.error('Image upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during image upload'
    });
  }
});

// @route   POST /api/upload/file
// @desc    Upload general file
// @access  Private
router.post('/file', auth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'File is required'
      });
    }

    const uploadDir = path.join(__dirname, '../uploads/files');
    await ensureUploadDir(uploadDir);

    // Generate unique filename while preserving extension
    const ext = path.extname(req.file.originalname);
    const filename = `${uuidv4()}${ext}`;
    const filepath = path.join(uploadDir, filename);

    // Save file
    await fs.writeFile(filepath, req.file.buffer);

    const fileUrl = `/uploads/files/${filename}`;

    res.json({
      success: true,
      message: 'File uploaded successfully',
      data: {
        url: fileUrl,
        filename,
        originalName: req.file.originalname,
        size: req.file.size,
        mimeType: req.file.mimetype
      }
    });

  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during file upload'
    });
  }
});

// @route   POST /api/upload/multiple
// @desc    Upload multiple files
// @access  Private
router.post('/multiple', auth, upload.array('files', 10), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'At least one file is required'
      });
    }

    const uploadDir = path.join(__dirname, '../uploads/files');
    await ensureUploadDir(uploadDir);

    const uploadedFiles = [];

    for (const file of req.files) {
      const ext = path.extname(file.originalname);
      const filename = `${uuidv4()}${ext}`;
      const filepath = path.join(uploadDir, filename);

      // Process based on file type
      if (file.mimetype.startsWith('image/')) {
        await sharp(file.buffer)
          .resize(1024, 1024, { fit: 'inside', withoutEnlargement: true })
          .jpeg({ quality: 85 })
          .toFile(filepath);
      } else {
        await fs.writeFile(filepath, file.buffer);
      }

      uploadedFiles.push({
        url: `/uploads/files/${filename}`,
        filename,
        originalName: file.originalname,
        size: file.size,
        mimeType: file.mimetype
      });
    }

    res.json({
      success: true,
      message: `${uploadedFiles.length} files uploaded successfully`,
      data: { files: uploadedFiles }
    });

  } catch (error) {
    console.error('Multiple upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during file upload'
    });
  }
});

// @route   DELETE /api/upload/:filename
// @desc    Delete uploaded file
// @access  Private
router.delete('/:filename', auth, async (req, res) => {
  try {
    const { filename } = req.params;
    const { type = 'files' } = req.query; // files, images, avatars

    const allowedTypes = ['files', 'images', 'avatars'];
    if (!allowedTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid file type'
      });
    }

    const filepath = path.join(__dirname, `../uploads/${type}`, filename);

    try {
      await fs.access(filepath);
      await fs.unlink(filepath);

      res.json({
        success: true,
        message: 'File deleted successfully'
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }

  } catch (error) {
    console.error('Delete file error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during file deletion'
    });
  }
});

// @route   GET /api/upload/info/:filename
// @desc    Get file information
// @access  Private
router.get('/info/:filename', auth, async (req, res) => {
  try {
    const { filename } = req.params;
    const { type = 'files' } = req.query;

    const allowedTypes = ['files', 'images', 'avatars'];
    if (!allowedTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid file type'
      });
    }

    const filepath = path.join(__dirname, `../uploads/${type}`, filename);

    try {
      const stats = await fs.stat(filepath);
      
      let metadata = {
        filename,
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        url: `/uploads/${type}/${filename}`
      };

      // If it's an image, get additional metadata
      if (type === 'images' || type === 'avatars') {
        try {
          const imageMetadata = await sharp(filepath).metadata();
          metadata = {
            ...metadata,
            width: imageMetadata.width,
            height: imageMetadata.height,
            format: imageMetadata.format,
            channels: imageMetadata.channels
          };
        } catch (sharpError) {
          // Not a valid image file
        }
      }

      res.json({
        success: true,
        data: metadata
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }

  } catch (error) {
    console.error('Get file info error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while getting file information'
    });
  }
});

// Serve static files
router.use('/uploads', express.static(path.join(__dirname, '../uploads')));

module.exports = router;