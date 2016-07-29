# Getting Started with Programming

``` js
"cake".length
```

> What can we use JavaScript for?

> * make websites respond to user interaction

> * build apps and games (e.g. blackjack)

> * access information on the Internet (e.g. find out the top trending words on Twitter by topic)

> * organize and present data (e.g. automate spreadsheet work; data visualization)
I

```javascript
confirm('This is an example of using JS to create some interaction on a website. Click OK to continue!');
```

## Interactive JavaScript
弹出一个消息框（警告）：

```javascript
confirm("I feel awesome!");
confirm("I am ready to go.");
```

弹出一个问题填一个空：

```javascript
prompt("What is your name?");
prompt("What is Ubuntu?");
```
## Data Types

a. numbers are quantities, just like you're used to. You can do math with them.

b. strings are sequences of characters, like the letters a-z, spaces, and even numbers. These are all strings: "Ryan", "4" and "What is your name?" Strings are extremely useful as labels, names, and content for your programs.

c. A boolean is either true or false.

## Using console.log

> console.log() will take whatever is inside the parentheses and log it to the console below your code—that's why it's called console.log()!

> This is commonly called printing out.

```
console.log(2 * 5)
console.log("Hello")
```
## If - Else
```
if( "myName".length >= 7 ) {
    console.log("You have a long name!");
}
else {
    console.log("You have a short name!");  
}
```

> * Confirm and prompt

> We can make pop-up boxes appear! 

> ```confirm("I am ok");
prompt("Are you ok?");```

> * Data types

> a. numbers (e.g. 4.3, 134)

> b. strings (e.g. "dogs go woof!", "JavaScript expert")

> c. booleans (e.g. false, 5 > 4)

> * Conditionals

> If the first condition is met, execute the first code block. If it is not met, execute the code in the else block. See the code on the right for another example.

## Substrings

1. First 3 letters of "Batman"
`"Batman".substring(0,3);`

2. From 4th to 6th letter of "laptop"
`"laptop".substring(3,6);`

## Variables
```
Example:
a. var myName = "Leng";
b. var myAge = 30;
c. var isOdd = true;
```
> Data types

strings (e.g. "dogs go woof!")
numbers (e.g. 4, 10)
booleans (e.g. false, 5 > 4)

> Variables
We store data values in variables. We can bring back the values of these variables by typing the variable name.

> Manipulating numbers & strings
comparisons (e.g. >, <=)
modulo (e.g. %)
string length (e.g. "Emily".length;)
substrings (e.g. "hi".substring(0, 1);)

>console.log( ) 
Prints into the console whatever we put in the parentheses.

```
// Check if the user is ready to play!

confirm("I am ready to play!");

var age = prompt("What's your age");

if(age <= 13)
{
    console.log("You are allowed.");
}
else
{
    console.log("Go play on!");
}

console.log("You are at a Justin Bieber concert, and you hear this lyric 'Lace my shoes off, start racing.'");

console.log("Suddenly, Bieber stops and says, 'Who wants to race me?'");

var userAnswer = prompt("Do you want to race Bieber on stage?");

if(userAnswer =="yes"){
    console.log("You and Bieber start racing. It's neck and neck! You win by a shoelace!");
}
else
{
    console.log("Oh no! Bieber shakes his head and sings 'I set a pace, so I can race without pacing.'");
}

var feedback = prompt("Please rate my game out of 10.");

if(feedback > 8){
    console.log("Thank you! We should race at the next concert!");
}
else
{
    console.log("I'll keep practicing coding and racing.");
}
```

# Introduction to function in JS
```
var greeting = function (name) {
    console.log("Great to see you," + " " + name);
    return name;
};
```
>The var keyword declares a variable named functionName.
The keyword function tells the computer that functionName is a function and not something else.
Parameters go in the parentheses. The computer will look out for it in the code block.
The code block is the reusable code that is between the curly brackets { }. Each line of code inside { } must end with a semi-colon.
The entire function ends with a semi-colon.

## Global vs Local Variables
Using my_number without the var keyword refers to the global variable that has already been declared outside the function in line 1. However, if you use the var keyword inside a function, it declares a new local variable that only exists within that function.

## Build "Rock, Paper, Scissors"
Rock paper scissors is a classic 2 player game. Each player chooses either rock, paper or scissors. The possible outcomes:

Rock destroys scissors.

Scissors cut paper.

Paper covers rock.

Our code will break the game into 3 phases:
a. User makes a choice
b. Computer makes a choice
c. A compare function will determine who wins

```javascript
var userChoice = prompt("Do you choose rock, paper or scissors?");
var computerChoice = Math.random();
if (computerChoice < 0.34) {
	computerChoice = "rock";
} 
else if(computerChoice <= 0.67) {
	computerChoice = "paper";
}
else {
	computerChoice = "scissors";
} 

var compare = function(choice1,choice2){
    if(choice1 === choice2)
    {
        return "The result is a tie!";
    }
    else if(choice1 === "rock")
    {
        if(choice2 === "scissors")
        {
            return "rock wins";
        }
        else{
            return "paper wins";
        }
    }
    else if(choice1 === "paper")
    {
        if(choice2 === "rock")
        {
            return "paper wins";
        }
        else{
            return "scissors wins";
        }
    }
    else
    {
        if(choice2 === "rock")
        {
            return "rock wins";
        }
        else{
            return "scissors wins";
        }
    }
}

compare(userChoice,computerChoice);
```
