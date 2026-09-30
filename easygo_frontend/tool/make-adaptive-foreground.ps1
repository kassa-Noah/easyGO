# Builds the foreground layer for Android's adaptive launcher icon.
#
# Run after replacing `assets/images/easygo_logo.png`, then run
# `dart run flutter_launcher_icons` from the project root.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tool/make-adaptive-foreground.ps1
#
# Why this exists at all.
#
# Android 8 and later do not draw a launcher icon as given. They take two layers
# - a background and a foreground - and mask them into whatever shape the
# launcher uses: a circle, a squircle, a rounded square. The mask eats roughly
# the outer third of the foreground on every side, and only the central 66% is
# guaranteed to survive.
#
# So handing the icon generator the logo as it stands would cut the road, the
# bus and the wordmark off at the edges. This draws the logo smaller, centred, on
# a transparent canvas, so the whole lockup lands inside the safe zone. The
# background layer is white, matching the logo's own background, which is why the
# result reads as the logo on white rather than as a white square inside another
# shape.
#
# The output is deliberately outside `assets/images/`: it is build input, and
# nothing in the running app needs to carry it in the bundle.
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent

$logo = Join-Path $root 'assets\images\easygo_logo.png'
$target = Join-Path $root 'assets\icon\adaptive_foreground.png'

# 62% sits comfortably inside the 66% safe zone, which leaves a circular mask
# room to round the corners of the wordmark off rather than clip them.
$scale = 0.62

$canvas = 1024

if (-not (Test-Path $logo)) {
    throw "No logo at $logo. The foreground is cut from it."
}

$source = [System.Drawing.Image]::FromFile($logo)

$drawn = [int]($canvas * $scale)
$offset = [int](($canvas - $drawn) / 2)

$bitmap = New-Object System.Drawing.Bitmap($canvas, $canvas)

$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

$graphics.Clear([System.Drawing.Color]::Transparent)

# The defaults leave visible steps on curved shapes and small text, and this
# logo has both.
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

$graphics.DrawImage($source, $offset, $offset, $drawn, $drawn)

$graphics.Dispose()
$source.Dispose()

New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null

$bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)

$bitmap.Dispose()

"foreground written: $target (logo drawn at $drawn px inside $canvas)"
