# Introsort in <text>&beta;</text>-assembly.

## Introduction to <text>&beta;</text>-assembly.
The <text>&beta;</text>-assembly is a pedagogical assembly language designed for the Computation Structures M.I.T. course. This programming language program the associated pedagogical <text>&beta;</text>-machine which has the following characteristics
* It's a simple, pedagogical RISC computer;
* It has a 32-bits architecture, which means that 
  - All registers are on 32-bits (4 bytes);
  - The memory address space is 32-bits length;
* Each of its instruction is 32-bits (4 bytes) length;
* It has 32 registers (from 0 to 31) (register 31 (R31) is hardwired to 0). `Reg[x]` denotes thecontent of register `x`;
* Its memory addresses are on 32-bits. `Mem[x]` denotes the word (32-bits) at address `x`. The two least significant bits of `x` are ignored (0);
* The program counter `PC` is on 32-bits, and can only be a multiple of 4 (the two least significant bits are 0);

## The translated introsort. 
Introsort is an efficient sorting algorithm published by David R. Musser in 1997. This variant of Quicksort improves the latter worst-time complexity from  <text>&Theta;(n<sup>2</sup>)</text> down to <text>&Theta;(n log(n))</text> using several tricks. The most important one consists in switching from Quicksort to Heapsort when the number of recursive calls exceeds <text>log<sub>2</sub> n<sup>2</sup></text> where n is the size
of the array. It also uses a median-of-3 pivot selection strategy. It is not necessary to
fully understand the algorithm to make the project, although it is advised to get at least
a basic understanding. In order to do so, you can refer to the original article or other
resources online. The following C program has been used as reference in order to implement the introsort in <text>&beta;</text>-assembly.

```c
void swap(int* a, int* b) {
  int tmp = *a;
  *a = *b;
  *b = tmp;
}

void heapify(int* array, int size, int index) {
  while (index < size) {
    int largest = index;
    int left = index * 2 + 1, right = (index + 1) * 2;
    if (left < size && array[largest] < array[left]) {
      largest = left;
    }
    if (right < size && array[largest] < array[right]) {
      largest = right;
    }
    if (largest != index) {
      swap(array + largest, array + index);
      index = largest;
    } else {
      break;
    }
  }
}

void heapsort(int* array, int size) {
  for (int i = (size / 2) - 1; i >= 0; --i) {
    heapify(array, size, i);
  }
  for (int i = size - 1; i > 0; --i) {
    swap(array, array + i);
    heapify(array, i, 0);
  }
}

int median3(int* array, int n) {
  int a = array[0], b = array[n / 2], c = array[n - 1];
  if (a < b) {
    if (b < c) {
      return b;
    } else if (a < c) {
      return c;
    } else {
      return a;
    }
  } else if (b < c) {
    if (a < c) {
      return a;
    } else {
      return c;
    }
  } else {
    return b;
  }
}

void introsort(int* array, int n, int maxd) {
  while (n > 1) {
    if (maxd <= 0) {
      heapsort(array, n);
      return;
    }
    maxd -= 1;
    int pivot = median3(array, n);

    // Three-way partition.
    int i = 0, l = 0, r = n;
    while (i < r) {
      if (array[i] < pivot) {
        swap(array + i, array + l);
        i += 1;
        l += 1;
      } else if (array[i] > pivot) {
        r -= 1;
        swap(array + i, array + r);
      } else {
        i += 1;
      }
    }
    introsort(array, l, maxd);
    array += r;
    n -= r;
  }
}

void sort(int* array, int size) {
  if (size == 0) {
    return;
  }
  int maxd = 2 * (int)log2(size);
  introsort(array, size, maxd);
}
```

## Usage
This language can be interpreted using the <text>&beta;</text>-assembly interpretor, BSim. This simulator is freely available on the Internet. Launching the code is done by 
```bash
java -jar bsim.jar beta.uasm main.asm util.asm introsort.asm heapsort.asm
```
from the folder containing all the files.


