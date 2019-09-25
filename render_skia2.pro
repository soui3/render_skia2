TEMPLATE = subdirs
TARGET = render_skia2
CONFIG(x64){
TARGET = $$TARGET"64"
}

SUBDIRS += skia
SUBDIRS += render-skia2

render_skia2.depends += skia

