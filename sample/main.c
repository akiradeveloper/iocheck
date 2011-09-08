#include <stdio.h>

int main(void){
  int i;
  int p = 1;
  
  for(i=1; i<=9; i++){
    p *= i;
  }
  printf("%d\n", p);
  return 0;
}

/*
  Refactoring Exercise!
  After rake iocheck:update and rake iocheck:lock,
  do "extract method" refactoring.
  Implement this function.
  Again, rake iocheck and see no behavior changed.
*/
int multiply(int from, int to);
/*
int main(void){
  printf("%d\n", multiply(1, 9));
  return 0;
}
*/
