const fs = require('fs');
const path = require('path');

// Create public directory if it doesn't exist
const publicDir = path.join(__dirname, '..', 'public');
if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true });
}

// Create CSS directory if it doesn't exist
const targetCssDir = path.join(publicDir, 'css');
if (!fs.existsSync(targetCssDir)) {
  fs.mkdirSync(targetCssDir, { recursive: true });
}

// Copy CSS files from src/styles to public/css
const stylesDir = path.join(__dirname, '..', 'src', 'styles');
if (fs.existsSync(stylesDir)) {
  fs.readdirSync(stylesDir)
    .filter(file => file.endsWith('.css'))
    .forEach(file => {
      const sourcePath = path.join(stylesDir, file);
      const targetPath = path.join(targetCssDir, file);
      fs.copyFileSync(sourcePath, targetPath);
      console.log(`Copied CSS: ${file} to ${targetPath}`);
    });
}

// Copy HTML templates from src/templates to public
const templatesDir = path.join(__dirname, '..', 'src', 'templates');
if (fs.existsSync(templatesDir)) {
  fs.readdirSync(templatesDir)
    .filter(file => file.endsWith('.html'))
    .forEach(file => {
      const sourcePath = path.join(templatesDir, file);
      const targetFile = file.replace('.template', ''); // Remove .template from filename
      const targetPath = path.join(publicDir, targetFile);
      fs.copyFileSync(sourcePath, targetPath);
      console.log(`Copied HTML: ${file} to ${targetPath}`);
    });
}

console.log('Asset copy complete!');
