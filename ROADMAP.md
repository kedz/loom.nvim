#
Possible inputs:

- A buffer
- A selected region
- A user input string
- Templating the above `Please answer the question: %y`
- Buffer template with user input

Possible outputs:
- To your current cursor location
- to an existing buffer location 
- to a new buffer


:llm buffer l "This is an argument" 

:LlmCurBuf 



Think about ways to comine user input with a buffer.



options to append to end, include debug info


`<leader>lb` send current window to llm

commands to ollama
- list loaded models
- load a model
- edit the model file

- other ideas
-- load a template and proces a jsonl file of template fillers
-- llm diff proposal (e.g spell check this buffer)
-- llm next edit point in code generation
-- figure out chat version

template ideas
- retrieve webpages
- do rag on something

