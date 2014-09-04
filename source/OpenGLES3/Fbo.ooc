/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

import lib/gles, Texture


Fbo: class {
  _backend: UInt
  _bufferCount: UInt
  _buffers: UInt*

  _width: UInt
  _height: UInt

  init: func (=_width, =_height)
  dispose: func {
    glDeleteFramebuffers(1, _backend&)
  }
  bind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, _backend)
    glViewport(0, 0, this _width, this _height)
  }
  bindRead: func {
    glBindFramebuffer(GL_READ_FRAMEBUFFER, _backend)
  }
  bindDraw: func {
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _backend)
  }
  unbind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glDrawBuffers(this _bufferCount, this _buffers)
  }
  clear: func {
    glClear(GL_COLOR_BUFFER_BIT)
  }
  _generate: func ~fromTextures (textures: Texture[]) -> Bool {
    glGenFramebuffers(1, this _backend&)
    glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
    this _bufferCount = textures length
    this _buffers = gc_malloc(this _bufferCount * UInt size) as UInt*

    for (i in 0..textures length) {
      this _buffers[i] = GL_COLOR_ATTACHMENT0 + i
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, textures[i] _backend, 0)
    }

    /* Check FBO status */
    status: UInt = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
      raise("Framebuffer Object creation failed")
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    true
  }
  setViewport: static func (x: UInt, y: UInt, width: UInt, height: UInt) {
    glViewport(x, y, width, height)
  }
  create: static func (textures: Texture[], width: UInt, height: UInt) -> This {
    result := This new(width, height)
    result _generate(textures) ? result : null
  }


}