# The wallpaper is generated at build time rather than committed, so the
# repository carries no binary assets and the image always follows the palette.
#
# Topographic contour lines are drawn from a smoothed random field: posterising
# it into bands and taking the edges of those bands leaves one line per band.
{ pkgs, palette }:

let
  width = 2880;
  height = 1800;
  canvas = "${toString width}x${toString height}";
in
pkgs.runCommand "catppuccin-mocha-topography.png"
  {
    nativeBuildInputs = [ pkgs.imagemagick ];
  }
  ''
    # A fixed seed keeps the random field, and therefore the whole image,
    # identical on every machine that builds this.
    magick -seed 20260828 -size 160x100 xc:'${palette.crust}' \
      \( -size 160x100 xc:none -fill '${palette.mauve}' -draw 'circle 34,24 34,74' \
         -channel A -evaluate multiply 0.34 +channel \) -compose over -composite \
      \( -size 160x100 xc:none -fill '${palette.blue}' -draw 'circle 126,80 126,140' \
         -channel A -evaluate multiply 0.30 +channel \) -compose over -composite \
      \( -size 160x100 xc:none -fill '${palette.pink}' -draw 'circle 140,18 140,46' \
         -channel A -evaluate multiply 0.20 +channel \) -compose over -composite \
      \( -size 160x100 xc:none -fill '${palette.sapphire}' -draw 'circle 16,86 16,118' \
         -channel A -evaluate multiply 0.18 +channel \) -compose over -composite \
      -blur 0x12 \
      -resize ${canvas}! \
      \( -size ${canvas} radial-gradient:'#ffffff'-'${palette.surface2}' \) \
      -compose multiply -composite \
      mesh.png

    magick -seed 20260828 -size 320x200 xc: +noise Random -blur 0x18 -normalize \
      -resize ${canvas}! -posterize 18 -edge 1 -threshold 12% -blur 0x0.6 \
      contours.png

    magick -size ${canvas} gradient:'${palette.mauve}'-'${palette.sapphire}' lines.png

    magick -seed 20260828 mesh.png lines.png \
      \( contours.png -evaluate multiply 0.60 \) -compose over -composite \
      -attenuate 0.015 +noise Gaussian -depth 8 \
      $out
  ''
