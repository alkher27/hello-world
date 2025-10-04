const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Serve static files from public directory
const publicDir = path.join(__dirname, 'public');
app.use(express.static(publicDir));

// Simple API endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Fallback to index.html for root
app.get('/', (req, res) => {
  res.sendFile(path.join(publicDir, 'index.html'));
});

// Serve images directory under /images
const imagesDir = path.join(__dirname, 'images');
app.use('/images', express.static(imagesDir));

// Example route listing available images
app.get('/api/images', (req, res) => {
  const fs = require('fs');
  fs.readdir(imagesDir, (err, files) => {
    if (err) {
      res.status(500).json({ error: 'Failed to list images' });
      return;
    }
    const imageFiles = files.filter((f) => /\.(png|jpg|jpeg|gif|webp|svg)$/i.test(f));
    res.json({ images: imageFiles.map((f) => `/images/${f}`) });
  });
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
