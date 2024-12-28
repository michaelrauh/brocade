mix run -e "Ortho.example()"

./deps/eflame/stack_to_flame.sh < stacks.out > flame.svg
open flame.svg
rm stacks.out