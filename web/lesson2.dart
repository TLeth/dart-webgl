// Copyright (c) 2013, John Thomas McDole.
/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
part of learn_gl;

/**
 * Staticly draw a triangle and a square - With Color!
 */
class Lesson2 extends Lesson {
  GlProgram program;

  Buffer triangleVertexPositionBuffer;
  Buffer squareVertexPositionBuffer;
  Buffer triangleVertexColorBuffer;
  Buffer squareVertexColorBuffer;

  Lesson2() {
    program = new GlProgram('''
          precision mediump float;

          varying vec4 vColor;

          void main(void) {
            gl_FragColor = vColor;
          }
        ''', '''
          attribute vec3 aVertexPosition;
          attribute vec4 aVertexColor;

          uniform mat4 uMVMatrix;
          uniform mat4 uPMatrix;

          varying vec4 vColor;

          void main(void) {
              gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
              vColor = aVertexColor;
          }
        ''', ['aVertexPosition', 'aVertexColor'], ['uMVMatrix', 'uPMatrix']);
    gl.useProgram(program.program);

    // Allocate and build the two buffers we need to draw a triangle and box.
    // createBuffer() asks the WebGL system to allocate some data for us
    triangleVertexPositionBuffer = gl.createBuffer();

    // bindBuffer() tells the WebGL system the target of future calls
    gl.bindBuffer(ARRAY_BUFFER, triangleVertexPositionBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([0.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, -1.0, 0.0]), STATIC_DRAW);

    triangleVertexColorBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, triangleVertexColorBuffer);
    var colors = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0];
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(colors), STATIC_DRAW);

    squareVertexPositionBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, squareVertexPositionBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([1.0, 1.0, 0.0, -1.0, 1.0, 0.0, 1.0, -1.0, 0.0, -1.0, -1.0, 0.0]), STATIC_DRAW);

    squareVertexColorBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, squareVertexColorBuffer);
    colors = [0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0];
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(colors), STATIC_DRAW);

    // Specify the color to clear with (black with 100% alpha) and then enable
    // depth testing.
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
  }

  void drawScene(num viewWidth, num viewHeight, num aspect) {
    // Basic viewport setup and clearing of the screen
    gl.viewport(0, 0, viewWidth, viewHeight);
    gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
    gl.enable(DEPTH_TEST);
    gl.disable(BLEND);

    // Setup the perspective - you might be wondering why we do this every
    // time, and that will become clear in much later lessons. Just know, you
    // are not crazy for thinking of caching this.
    pMatrix = Matrix4.perspective(45.0, aspect, 0.1, 100.0);

    // First stash the current model view matrix before we start moving around.
    mvPushMatrix();

    mvMatrix.translate([-1.5, 0.0, -7.0]);

    // Here's that bindBuffer() again, as seen in the constructor
    gl.bindBuffer(ARRAY_BUFFER, triangleVertexPositionBuffer);
    // Set the vertex attribute to the size of each individual element (x,y,z)
    gl.vertexAttribPointer(program.attributes['aVertexPosition'], 3, FLOAT, false, 0, 0);

    gl.bindBuffer(ARRAY_BUFFER, triangleVertexColorBuffer);
    gl.vertexAttribPointer(program.attributes['aVertexColor'], 4, FLOAT, false, 0, 0);

    setMatrixUniforms();
    // Now draw 3 vertices
    gl.drawArrays(TRIANGLES, 0, 3);

    // Move 3 units to the right
    mvMatrix.translate([3.0, 0.0, 0.0]);

    // And get ready to draw the square just like we did the triangle...
    gl.bindBuffer(ARRAY_BUFFER, squareVertexPositionBuffer);
    gl.vertexAttribPointer(program.attributes['aVertexPosition'], 3, FLOAT, false, 0, 0);

    gl.bindBuffer(ARRAY_BUFFER, squareVertexColorBuffer);
    gl.vertexAttribPointer(program.attributes['aVertexColor'], 4, FLOAT, false, 0, 0);

    setMatrixUniforms();
    // Except now draw 2 triangles, re-using the vertices found in the buffer.
    gl.drawArrays(TRIANGLE_STRIP, 0, 4);

    // Finally, reset the matrix back to what it was before we moved around.
    mvPopMatrix();
  }

  /**
   * Write the matrix uniforms (model view matrix and perspective matrix) so
   * WebGL knows what to do with them.
   */
  setMatrixUniforms() {
    gl.uniformMatrix4fv(program.uniforms['uPMatrix'], false, pMatrix.buf);
    gl.uniformMatrix4fv(program.uniforms['uMVMatrix'], false, mvMatrix.buf);
  }

  void animate(num now) {
    // We're not animating the scene, but if you want to experiment, here's
    // where you get to play around.
  }

  void handleKeys() {
    // We're not handling keys right now, but if you want to experiment, here's
    // where you'd get to play around.
  }
}
