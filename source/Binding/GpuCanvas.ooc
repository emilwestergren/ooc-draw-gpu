//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
use ooc-math
import OpenGLES3/Fbo, OpenGLES3/Quad
import GpuImage, GpuMap, Surface, GpuMonochrome, GpuBgra, GpuBgr, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar

GpuCanvas: abstract class extends Surface {
  _monochromeToMonochrome: static const GpuMapMonochrome
  _bgrToBgr: static const GpuMapBgr
  _bgraToBgra: static const GpuMapBgra
  _uvToUv: static const GpuMapUv

  init: func {
    if(This _monochromeToMonochrome == null)
      This _monochromeToMonochrome = GpuMapMonochrome new()
    if(This _bgrToBgr == null)
      This _bgrToBgr = GpuMapBgr new()
    if(This _bgraToBgra == null)
      This _bgraToBgra = GpuMapBgra new()
    if(This _uvToUv == null)
      This _uvToUv = GpuMapUv new()
  }
  dispose: abstract func

  setResolution: func (resolution: IntSize2D) {
    Fbo setViewport(0, 0, resolution width, resolution height)
  }
}

GpuCanvasPacked: class extends GpuCanvas {
  _renderTarget: Fbo

  init: func {
    super()
  }
  dispose: func {
    this _renderTarget dispose()
  }
  draw: func ~Monochrome (image: GpuMonochrome, transform: FloatTransform2D) {
    This _monochromeToMonochrome transform = transform
    This _monochromeToMonochrome ratio = image ratio
    this draw(image, This _monochromeToMonochrome)
  }
  draw: func ~Bgr (image: GpuBgr, transform: FloatTransform2D) {
    This _bgrToBgr transform = transform
    This _bgrToBgr ratio = image ratio
    this draw(image, This _bgrToBgr)
  }
  draw: func ~Bgra (image: GpuBgra, transform: FloatTransform2D) {
    This _bgraToBgra transform = transform
    This _bgraToBgra ratio = image ratio
    this draw(image, This _bgraToBgra)
  }
  draw: func ~Uv (image: GpuUv, transform: FloatTransform2D) {
    This _uvToUv transform = transform
    This _uvToUv ratio = image ratio
    this draw(image, This _uvToUv)
  }
  _bind: func {
    this _renderTarget bind()
  }
  _unbind: func {
    this _renderTarget unbind()
  }
  _clear: func {
    this _renderTarget clear()
  }
  create: static func (image: GpuImage) -> This {
    result := This new()
    result _renderTarget = Fbo create(image textures, image size width, image size height)
    result _quad = Quad create()
    result _renderTarget != null ? result : null
  }
}

GpuCanvasYuv420Planar: class extends GpuCanvas {
  _y: GpuCanvasPacked
  _u: GpuCanvasPacked
  _v: GpuCanvasPacked

  init: func {
    super()
  }
  dispose: func {
    this _y dispose()
    this _u dispose()
    this _v dispose()
  }
  draw: func ~Yuv420Planar (image: GpuYuv420Planar, transform: FloatTransform2D) {
    GpuCanvas _monochromeToMonochrome transform = transform
    GpuCanvas _monochromeToMonochrome ratio = image ratio
    this _y draw(image y, GpuCanvas _monochromeToMonochrome)
    this _u draw(image u, GpuCanvas _monochromeToMonochrome)
    this _v draw(image v, GpuCanvas _monochromeToMonochrome)
  }
  _clear: func
  _bind: func
  _generate: func (image: GpuYuv420Planar) -> Bool {
    this _quad = Quad create()
    this _y = GpuCanvasPacked create(image y)
    this _u = GpuCanvasPacked create(image u)
    this _v = GpuCanvasPacked create(image v)
    this _quad != null && this _y != null && this _u != null && this _v != null
  }
  create: static func (image: GpuYuv420Planar) -> This {
    result := This new()
    result _generate(image) ? result : null
    result
  }
}

GpuCanvasYuv420Semiplanar: class extends GpuCanvas {
  _y: GpuCanvasPacked
  _uv: GpuCanvasPacked

  init: func {
    super()
  }
  dispose: func {
    this _y dispose()
    this _uv dispose()
  }
  draw: func ~GpuYuv420Semiplanar (image: GpuYuv420Semiplanar, transform: FloatTransform2D) {
    GpuCanvas _monochromeToMonochrome transform = transform
    GpuCanvas _monochromeToMonochrome ratio = image ratio
    this _y draw(image y, GpuCanvas _monochromeToMonochrome)
    this _uv draw(image uv, GpuCanvas _monochromeToMonochrome)
  }
  _clear: func
  _bind: func
  _generate: func (image: GpuYuv420Semiplanar) -> Bool {
    this _quad = Quad create()
    this _y = GpuCanvasPacked create(image y)
    this _uv = GpuCanvasPacked create(image uv)
    this _quad != null && this _y != null && this _uv != null
  }
  create: static func (image: GpuYuv420Semiplanar) -> This {
    result := This new()
    result _generate(image) ? result : null
    result
  }
}
