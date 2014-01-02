import std.stdio;
import std.string;
import matrix;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

void main() {
  // Dynamically link OpenGL 3 and SDL 2 libraries
  DerelictGL3.load();
  DerelictSDL2.load();

  // Create window
  SDL_Init(SDL_INIT_VIDEO);
  SDL_Window * window = SDL_CreateWindow(
    "Game",
	SDL_WINDOWPOS_UNDEFINED,
	SDL_WINDOWPOS_UNDEFINED,
	960,
	640,
	SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE
  );

  // Create OpenGL context inside of window
  SDL_GL_CreateContext(window);
  DerelictGL3.reload();

  // Define some static information for rendering
  glClearColor(0.0f, 0.0f, 0.4f, 0.04);
  static const GLfloat[] vboData = [
	-1.0f, -1.0f,  0.0f,
	 1.0f, -1.0f,  0.0f,
     0.0f,  1.0f,  0.0f
  ];

  // Load shaders
  GLuint GLSLProgram = loadShaders();
  GLint vertexPosition_modelspaceID = glGetAttribLocation(GLSLProgram, "vertexPosition_modelspace");
  
  // Create new vertex buffer from static information
  GLuint vertexBuffer;
  glGenBuffers(1, &vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
  glBufferData(
	GL_ARRAY_BUFFER,
    float.sizeof * 9,
	vboData.ptr,
	GL_STATIC_DRAW
  );
  
  // Start window event loop
  // - TODO: use perfect hash table with size of
  // - SDL_NUM_SCANCODE for dynamic key bindings
  SDL_Event event;
  bool running = true;
  bool fullscreen = false;
  while(running) {
	SDL_WaitEvent(&event);

	switch(event.type) {
	case SDL_QUIT:
	  running = false;
	  break;
	case SDL_KEYDOWN:
	  switch(event.key.keysym.scancode) {
	  case SDL_SCANCODE_ESCAPE:
		running = false;
		break;
	  case SDL_SCANCODE_F11:
		if(fullscreen) {
		  fullscreen = false;
		  SDL_SetWindowFullscreen(window, 0);
		} else {
		  fullscreen = true;
		  SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN_DESKTOP);
		}
		break;
	  case SDL_SCANCODE_E: // F in colemak
		writeln("Start forward");
		break;
	  case SDL_SCANCODE_D: // S in colemak
		writeln("Start backwards");
		break;
	  case SDL_SCANCODE_S: // R in colemak
		writeln("Start left");
		break;
	  case SDL_SCANCODE_F: // T in colemak
		writeln("Start right");
		break;
	  default:
		// Do nothing, D needs this for some reason...
	  }
	  break;
	case SDL_WINDOWEVENT:
	  if(event.window.event == SDL_WINDOWEVENT_RESIZED) {
		resize();
	  }
	  break;
	default:
	  // Do nothing, D needs this for some reason...
	}

	// Clear the display buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glUseProgram(GLSLProgram);
	glEnableVertexAttribArray(vertexPosition_modelspaceID);

	// Bind vertex data from vertexBuffer
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glVertexAttribPointer(
	  vertexPosition_modelspaceID,          
	  3,
	  GL_FLOAT,
	  GL_FALSE,
	  0,
	  cast(void*)0
    );

	// Draw triangle defined from vertex buffer
	glDrawArrays(GL_TRIANGLES, 0, 3);	
	
	glDisableVertexAttribArray(vertexPosition_modelspaceID);

	// Swap display buffers
	SDL_GL_SwapWindow(window);
  }

  // Clean up
  SDL_DestroyWindow(window);
  glDeleteBuffers(1, &vertexBuffer);
  SDL_Quit();
}

void resize() {
  writeln("Todo stuff");
}

// TODO: Handle this better
GLuint loadShaders() {
  // Define variables for handling compliation and linking errors
  GLint status, logLength;
  
  // Import shader source files
  const char * vShaderSource = toStringz(import("vertexShader.glsl"));
  const char * fShaderSource = toStringz(import("fragmentShader.glsl"));

  // Compile vertex shader
  writeln("Compiling vertex shader");
  
  GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vShader, 1, &vShaderSource, null);
  glCompileShader(vShader);

  // If there are compliation errors, display them
  glGetShaderiv(vShader, GL_COMPILE_STATUS, &status);
  if(status == GL_FALSE) {
	glGetShaderiv(vShader, GL_INFO_LOG_LENGTH, &logLength);
	
	auto vShaderLog = new char[logLength];
	glGetShaderInfoLog(vShader, logLength, null, vShaderLog.ptr);
	writeln(vShaderLog);
  } else {
	writeln("Success!");
  }

  // Compile fragment shader
  writeln("Compiling fragment shader");

  GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fShader, 1, &fShaderSource , null);
  glCompileShader(fShader);

  // If there are compliation errors, display them
  glGetShaderiv(fShader, GL_COMPILE_STATUS, &status);
  if(status == GL_FALSE) {
	glGetShaderiv(fShader, GL_INFO_LOG_LENGTH, &logLength);

	auto fShaderLog = new char[logLength];
	glGetShaderInfoLog(fShader, logLength, null, fShaderLog.ptr);
	writeln(fShaderLog);
  } else {
	writeln("Success!");
  }

  // Link the program
  writeln("Linking program");
  
  GLuint program = glCreateProgram();
  glAttachShader(program, vShader);
  glAttachShader(program, fShader);
  glLinkProgram(program);

  // If there are linking errors, display them
  glGetProgramiv(program, GL_LINK_STATUS, &status);
  if(status == GL_FALSE) {
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);

	// Display linking log
	auto programLog = new char[logLength];
	glGetProgramInfoLog(program, logLength, null, cast(GLchar*)programLog);
	writeln(programLog);
  } else {
	writeln("Success!");
  }

  // Cleanup
  glDeleteShader(vShader);
  glDeleteShader(fShader);

  return program;
}