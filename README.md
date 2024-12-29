# My what-todo list CLI

A simple tool to help pick an activity or chore when i need something todo.
I hope this will help fight decision paralysis that typically leads to watching TV more often than I would like.

(loosely inspired by https://github.com/todotxt/todo.txt)

## So what actually is it

This shell script automates creating and selecting activities in a todo.txt file.
Every entry follows the following form:

```
# id (priority) description [time limit] @category
24141 (B) go for jog [30min] @exercise @daily
```

Once a few of these are populated into your todo.txt file, you can select one randomly. Either from the total population, or from within a chosen category.

```
$ todo.sh get -c daily -c learning
> 9483 (B) read the news @daily @info
```

