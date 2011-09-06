#include <stdio.h>

int main(void){
  int i;
  int p = 1;
  
  for(i=1; i<10; i++){
    p *= i;
  }

  printf("%d\n", p);

  return 0;
}
