module matrix;

struct Matrix4(T) {
  float matrix[16];

  int opUnary(string s)() if (s == "*") {
    
  }
}