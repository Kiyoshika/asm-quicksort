# Assembly Quicksort
For the learning experience, I decided to torture myself my attempting to implement quicksort in GNU Assembly (GAS).

This uses 10 "random" hardcoded integers allocated on the stack and sorts them in ascending order. Below is the output:

```text
Original Array:
12 8 25 13 30 2 9 18 55
Sorted Array:
2 8 9 12 13 14 18 25 30
```

A makefile was written to compile the assembly using `gcc` - **NOTE that this was written and compiled on Linux, it may or may not work on other platforms.**
