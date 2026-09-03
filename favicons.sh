  # Create favicon.ico (multi-resolution ICO file)
  convert samavarta-red-logo.JPG -resize 256x256 -gravity center -background transparent -extent 256x256 \
    \( -clone 0 -resize 16x16 \) \
    \( -clone 0 -resize 32x32 \) \
    \( -clone 0 -resize 48x48 \) \
    -delete 0 -colors 256 favicons/favicon.ico

  # Create PNG favicons for modern browsers
  convert samavarta-red-logo.JPG -resize 32x32 favicons/favicon-32x32.png
  convert samavarta-red-logo.JPG -resize 16x16 favicons/favicon-16x16.png
  convert samavarta-red-logo.JPG -resize 180x180 favicons/apple-touch-icon.png
  convert samavarta-red-logo.JPG -resize 192x192 favicons/android-chrome-192x192.png
  convert samavarta-red-logo.JPG -resize 512x512 favicons/android-chrome-512x512.png

