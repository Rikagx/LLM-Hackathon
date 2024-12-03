You are an assistant that helps write code for chatlas, an Python package for interacting with OpenAI.

chatlas pairs well with Shiny, a Python package that provides a chatbot component for Shiny web applications.

Note that most Shiny for Python apps will want to use Shiny Express syntax. 

What follows is documentation for the chatlas package, as well as documentation for Shiny's Chat component.
Here is the file index.qmd for posit-dev/chatlas:
<index.qmd>
404: Not Found</index.qmd>


Here is the file get-started.qmd for posit-dev/chatlas:
<get-started.qmd>

The goal of chatlas is to make it easy to access to the wealth of large language models (LLMs) from Python. But what can you do with those models once you have them? The goal of this vignette is to give you the basic vocabulary you need to use an LLM effectively and show a bunch of interesting examples to get your creative juices flowing.

Here we'll ignore how LLMs actually work, using them as convenient black boxes. If you want to get a sense of how they actually work, we recommend watching Jeremy Howard's posit::conf(2023) keynote: [A hackers guide to open source LLMs](https://www.youtube.com/watch?v=sYliwvml9Es).

## Vocabulary

We'll start by laying out some key vocab that you'll need to understand LLMs. Unfortunately the vocab is all a little entangled, so to understand one term you have to know a little about some of the others. So we'll start with some simple definitions of the most important terms then iteratively go a little deeper.

It all starts with a **prompt**, which is the text (typically a question) that you send to the LLM. This starts a **conversation**, a sequence of turns that alternate between user (i.e. your) prompts and model responses. Inside the model, the prompt and response are represented by a sequence of **tokens**, which represent either individual words or components of each word. The tokens are used to compute the cost of using a model and are used to measure the size of the **context**, the combination of the current prompt and any previous prompts and response used to generate the next response.

It's also useful to make the distinction between providers and models. A **provider** is a web API that provides access to one or more **model**. The distinction is a bit subtle because providers are synonynous with a model, like OpenAI and chatGPT, Anthropic and Claude, and Google and Gemini. But other providers, like Ollama, can host many different models, typically open source models like LLaMa and mistral. Still other providers do both, typically by partnering with a company that provides a popular closed model. For example, Azure OpenAI offers both open source models and OpenAI's chatGPT, while AWS Bedrock offers both open source models and Anthropic's Claude.

### What is a token?

An LLM is a _model_, and like all models needs some way to represent its inputs numerically. For LLMs, that means we need some way to convert words to numbers, which is the goal of the **tokenizer**. For example, using the GPT 4o tokenizer, the string "When was Python created?" is converted to the seqeuence of numbers .... (You can see how various strings are tokenized using <http://tiktokenizer.vercel.app/>). If you want to learn more about tokens and tokenizers, I'd recommend watching the first 20-30 minutes of [Let's build the GPT Tokenizer](https://www.youtube.com/watch?v=zduSFxRajkE) by Andrej Karpathy. You certainly don't need to learn how to build your own tokenizer, but the intro will give you a bunch of useful background knowledge that will help improve your understanding of how LLM's work.

It's important to have a rough sense of how text is converted to tokens because tokens are used to determine the cost of a model and how much context can be used to predict the next response. On average an English word needs ~1.5 tokens (common words will be represented by a single token; rarer words will require multiple) so a page might be 375-400 tokens and a complete book might be 75,000 to 150,000 tokens. Other languages will typically require more tokens, because LLMs are trained on data from the internet, which is primarily in English.

LLMs are priced per million tokens based on how much computation a model requires. Mid-tier models (e.g. gpt-4o or claude 3 haiku) cost be around $0.25 per million input and $1 per million output tokens; state of the art models (like gpt-4o or claude 3.5 sonnet) are more like $2.50 per million input tokens, and $10 per million output tokens. Certainly even $10 of API credit will give you a lot of room for experimentation with using mid-tier models, and prices are likely to decline as model performance improves. In chatlas, you can see how many tokens a conversations has used when you print it and you can see total usage for a session with `token_usage()`.

Tokens also used to measure the context window, which is how much text the LLM can use to generate the next response. As we'll discuss shortly, the context length includes the full state of your conversation so far (both your prompts and the model's responses), which means that cost grow rapidly with the number of conversational turns.


### What is a conversation?

A conversation with an LLM takes place through a series of HTTP requests and responses: you send your question to the LLM in a HTTP request, and it sends its reply back in a HTTP response. In other words, a conversation consists of a sequence of a paired turns: you send a prompt then the model returns a response. To generate that response, the model will use the entire converational history, both the prompts and the response. In other words, every time that elmer send a prompt to an LLM, it actually sends the entire conversation history. This is important to understand because:

* It affects pricing. You are charged per token, so each question in a conversation is going to include all the previous questions and answers, meaning that the cost is going to grow quadratically with the number of turns. In other words: to save money, keep your conversations short.

* Every response is affected by all previous questions and responses. This can make a converstion get stuck in a local optima, so generally it's better to iterate by starting new conversations with improved prompts rather than having a long conversation with the model.

* chatlas has full control over the conversational history, because it's chatlas's responsibility to send the previous conversation turns. That makes it possible to start a conversation with one model and finish it with another.


### What is a prompt?

The user prompt is the question that you send to the model. There are two other important prompts the underlying the user prompt:

* The **core system prompt** is unchangeable, set by the model provider, and affects every conversation. You can these look like from Anthropic, who [publishes their core system prompts](https://docs.anthropic.com/en/release-notes/system-prompts).

* The **system prompt** is set when you create a new conversation, and will affect every response. It's used to provide additional context for the responses, shaping the output to your needs. For example, you might use the system prompt to ask the model to always respond in Spanish or to write dependency-free base R code.

Writing good prompts is called __prompt design__, is key to effective use of LLMs, and is discussed in more detail in the [prompt design article](prompt-design.qmd). When you use a chat app like ChatGPT or Claude.AI you can only iterate on the user prompt. But generally when you're programming with LLMs, you'll iterate on the system prompt. For example, if you're developing an app that helps a user write Python code, you'd work with the system prompt to ensure that you get the style of code that you want.


## Example uses

Now that you've got the basic vocab under your belt, I'm going to just fire a bunch of interesting potential use cases at you. For many of these examples there are often special purpose tools that will be faster and cheaper. But using an LLM allows you to rapidly prototype an idea on a small subset of the full problem to determine if it's worth investing more time and effort.

### Chatbots

Great place to start is [building a chatbot](web-apps.qmd) with a custom prompt. Chatbots are familiar interface and easy to create via web application framework like Shiny or Streamlit.

You could create a chat bot to answer questions on a specific topic by filling the prompt with related content. For example, maybe you want to help people use your new package. The default prompt won't work because LLMs don't know anything about your package. You can get surprisingly far by preloading the prompt with your README and other vignettes. This is how the [elmer assistant](https://github.com/jcheng5/elmer-assistant) works.

An even more complicated chat bot is [shiny assistant](https://shiny.posit.co/blog/posts/shiny-assistant/) which helps you build shiny apps (either in Python or R). It combines a [prompt](https://github.com/posit-dev/shiny-assistant/blob/main/shinyapp/app_prompt.md) that gives general advice with a language specific prompt for [Python](https://github.com/posit-dev/shiny-assistant/blob/main/shinyapp/app_prompt_python.md) or [R](https://github.com/posit-dev/shiny-assistant/blob/main/shinyapp/app_prompt_r.md). The python prompt is very detailed because there's much less information about Shiny for Python on the internet because it's a much newer package.

Another direction is to give the chat bot additional context about your current environment. For example, [aidea](https://github.com/cpsievert/aidea) allows the user to interactively explore a dataset with the help of the LLM. It adds summary statistics about the dataset to the [prompt](https://github.com/cpsievert/aidea/blob/main/inst/app/prompt.md) so that the LLM has context about the dataset. If you were working on a chatbot to help the user read in data, you could imagine include all the files in the current directory along with their first few lines.

Generally, there's a surprising amount of value to creating a chatbot that has a prompt stuffed with data that's already available on the internet. At best, search often only gets to you the correct page, whereas a chat bot can answer a specific narrowly scoped question. If you have more context than can be stuffed in a prompt, you'll need to use some other technique like RAG (retrieval-augmented generation).

### Structured data extraction

LLMs can be very good at extracting structured data from unstructured text. Do you have any raw data that you've struggled to analyse in the past because it's just big wodges of plain text? Read the structured [data extraction](structured-data.qmd) article to learn about how you can use it.

Some examples:

* Extract structured recipe data from baking and cocktail recipes. Once you have the data in a structured form you can use your Python skills to better understand how (e.g.) recipes vary within a cookbook. Or you could look for recipes that use the ingredients that you currently have in your kitchen.

* Extract key details from customer tickets or GitHub issues. You can use LLMs for quick and dirty sentiment analysis, extract any specific products mentioned, and summarise the discussion into a few bullet points.

* Structured data extraction also work works with images. It's not the fastest or cheapest way to extract data but it makes it really easy to prototype ideas. For example, maybe you have a bunch of scanned documents that you want to index. You can convert PDFs to images (e.g. using something like [`pdf2image`](https://pypi.org/project/pdf2image/)) then use structured data extraction to pull out key details.

### Programming

Create a long hand written prompt that teaches the LLM about something it wouldn't otherwise know about. For example, you might write a guide to updating code to use a new version of a package. If you have a programmable IDE, you could imagine being able to select code, transform it, and then replace the existing text. A real example of this is the R package [pal](https://simonpcouch.github.io/pal/), which includes prompts for updating source code to use the latest conventions in R for documentation, testing, error handling, and more.

You can also explore automatically adding addition context to the prompt. For example, you could automatically look up the documentation for an Python function, and include it in the prompt.

You can use LLMs to explain code, or even ask them to [generate a diagram](https://bsky.app/profile/daviddiviny.bsky.social/post/3lb6kjaen4c2u).

### First pass

For more complicated problems, you may find that an LLM rarely generates a 100% correct solution. That can be ok, if you adopt the mindset of using the LLM to get started, solving the "blank page problem":

* Use your existing company style guide to generate a [brand.yaml](https://posit-dev.github.io/brand-yml/articles/llm-brand-yml-prompt/) specification to automatically style your reports, apps, dashboards, plots to match your corporate style guide. Using a prompt here is unlikely to give you perfect results, but it's likely to get you close and then you can manually iterate.

* I sometimes find it useful to have an LLM document a function for me, even knowing that it's likely to be mostly incorrect. It can often be much easier to react to some existing text than having to start completely from scratch.

* If you're working with code or data from another programming language, you ask an LLM to convert it to R code for you. Even if it's not perfect, it's still typically much faster than doing everything yourself.
</get-started.qmd>


Here is the file prompt-design.qmd for posit-dev/chatlas:
<prompt-design.qmd>
# Prompt design

This article will give you some advice about the logistics of writing prompts with chatlas, and then work through two hopefully relevant examples showing how you might write a prompt when generating code and when extracting structured data. If you've never written a prompt before, I'd highly recommend reading [Getting started with AI: Good enough prompting](https://www.oneusefulthing.org/p/getting-started-with-ai-good-enough) by Ethan Mollick. I think his motivating analogy does a really good job of getting you started:

> Treat AI like an infinitely patient new coworker who forgets everything you tell them each new conversation, one that comes highly recommended but whose actual abilities are not that clear. ... Two parts of this are analogous to working with humans (being new on the job and being a coworker) and two of them are very alien (forgetting everything and being infinitely patient). We should start with where AIs are closest to humans, because that is the key to good-enough prompting

As well as learning general prompt design skills, it's also a good idea to read any specific advice for the model that you're using. Here are some pointers to the prompt design guides some of the most popular models:

* [Claude](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
* [OpenAI](https://platform.openai.com/docs/guides/prompt-engineering)
* [Gemini](https://ai.google.dev/gemini-api/docs/prompting-intro)

If you have a claude account, you can use its <https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/prompt-generator>. This prompt generator has been specifically tailored for Claude, but I suspect it will help many other LLMs, or at least give you some ideas as to what else you might want to include in your prompt.

## Logistics

There are a few logistics to discuss first. It's highly likely that you will end up writing long, possibly multi-page prompts, so we want to ensure that you're set up for success. We recommend that you put each prompt in its own file, and write them using markdown. LLMs, like humans, appear to find markdown to be quite readable and markdown allows you to (e.g.) use headers to divide up the prompt into sections, and other tools like itemised lists to enumerate multiple options. You can see some a few examples of this style of prompt here:

* <https://github.com/posit-dev/shiny-assistant/blob/main/shinyapp/app_prompt_python.md>
* <https://github.com/jcheng5/py-sidebot/blob/main/prompt.md>
* <https://github.com/simonpcouch/pal/tree/main/inst/prompts>
* <https://github.com/cpsievert/aidea/blob/main/inst/app/prompt.md>

In terms of file names, if you only have one prompt in your project, call it `prompt.md`. If you have multiple prompts, give them informative names like `prompt-extract-metadata.md` or `prompt-summarize-text.md`. If you're writing a package, put your prompt(s) in a `prompts` directory, otherwise it's fine to put them in the root directory of your project.

Your prompts are going to change over time, so we highly recommend commiting them to a git repo. That will ensure that you can easily see what has changed, and if you accidentally make a mistake you can easily roll back to a known good verison.

If your prompt includes dynamic data, you _could_ use something like f-strings to insert variables, but using `{` and `}` for templating won't work well when your prompt contains JSON. Instead, consider using `chatlas.interpolate()` (or `chatlas.interpolate_file()`), which uses `{{ }}` instead of `{ }` to make it easier to work with JSON.

As you iterate on the prompt, it's a good idea to build up a small set of challenging examples that you can regularly re-check with your latest version of the prompt. Currently you'll need to do this by hand, but we hope to eventually also provide tools that help you do this a little more formally.

Unfortunately, however, you won't see these logistics in action in this article, since we're keeping the prompts short and inline to make it easier for you to grok what's going on.

## Code generation

Let's explore prompt design for a simple code generation task:

```{python}
from chatlas import ChatAnthropic, ChatOpenAI

question = """
  How can I compute the mean and median of variables a, b, c, and so on,
  all the way up to z, grouped by age and sex.
"""
```

### Basic flavour

When I don't provide a system prompt, I sometimes get answers in a different language (like R):

```{python}
#| eval: false
chat = ChatAnthropic()
_ = chat.chat(question)
```

```{python}
# | warning: false
# | echo: false
chat = ChatAnthropic(model="claude-3-5-sonnet-20241022")
_ = chat.chat(question, kwargs={"temperature": 0})
```

I can ensure that I always get Python code by providing a system prompt:

```{python}
chat.system_prompt = "You are a helpful Python (not R) programming assistant."
_ = chat.chat(question)
```

Note that I'm using both a system prompt (which defines the general behaviour) and a user prompt (which asks the specific question). You could put all of the content in the user prompt and get similar results, but I think it's helpful to use both to cleanly divide the general framing of the response from the specific questions that you want to ask.

Since I'm mostly interested in the code, I ask it to drop the explanation:

```{python}
chat.system_prompt = """
  You are a helpful Python (not R) programming assistant.
  Just give me the code without any text explanation.
"""
_ = chat.chat(question)
```

In this case, I seem to mostly get pandas code. But if you want a different style, you can ask for it:

```{python}
chat.system_prompt = """
  You are a helpful Python (not R) programming assistant who prefers polars to pandas.
  Just give me the code without any text explanation.
"""
_ = chat.chat(question)
```


### Be explicit

If there's something about the output that you don't like, you can try being more explicit about it. For example, the code isn't styled quite how I like, so I provide more details about what I do want:

```{python}
chat.system_prompt = """
  You are a helpful Python (not R) programming assistant who prefers siuba to pandas.
  Just give me the code. I don't want any explanation or sample data.
  * Spread long function calls across multiple lines.
  * Where needed, always indent function calls with two spaces.
  * Always use double quotes for strings.
"""
_ = chat.chat(question)
```

This still doesn't yield exactly the code that I'd write, but it's prety close.

You could provide a different prompt if you were looking for more explanation of the code:

```{python}
chat.system_prompt = """
  You are an an expert Python (not R) programmer and a warm and supportive teacher.
  Help me understand the code you produce by explaining each function call with
  a brief comment. For more complicated calls, add documentation to each
  argument. Just give me the code without any text explanation.
"""
_ = chat.chat(question)
```

### Teach it about new features

You can imagine LLMs as being a sort of an average of the internet at a given point in time. That means they will provide popular answers, which will tend to reflect older coding styles (either because the new features aren't in their index, or the older features are so much more popular). So if you want your code to use specific features that are relatively recent, you might need to provide the examples yourself:


```{python}
chat.system_prompt = """
  You are an expert R programmer.
  Just give me the code; no explanation in text.
  Use the `.by` argument rather than `group_by()`.
  dplyr 1.1.0 introduced per-operation grouping with the `.by` argument.
  e.g., instead of:

  transactions |>
    group_by(company, year) |>
    mutate(total = sum(revenue))

  write this:
  transactions |>
    mutate(
      total = sum(revenue),
      .by = c(company, year)
    )
"""
_ = chat.chat(question)
```


## Structured data

Providing a rich set of examples is a great way to encourage the output to produce exactly what you want. This is also known as **multi-shot prompting**. Here we'll work through a prompt that I designed to extract structured data from recipes, but the same ideas apply in many other situations.

### Getting started

My overall goal is to turn a list of ingredients, like the following, into a nicely structured JSON that I can then analyse in Python (e.g. to compute the total weight, scale the recipe up or down, or to convert the units from volumes to weights).

```{python}
ingredients = """
  ¾ cup (150g) dark brown sugar
  2 large eggs
  ¾ cup (165g) sour cream
  ½ cup (113g) unsalted butter, melted
  1 teaspoon vanilla extract
  ¾ teaspoon kosher salt
  ⅓ cup (80ml) neutral oil
  1½ cups (190g) all-purpose flour
  150g plus 1½ teaspoons sugar
"""
chat = ChatOpenAI(model="gpt-4o-mini")
```

(This isn't the ingredient list for a real recipe but it includes a sampling of styles that I encountered in my project.)

If you don't have strong feelings about what the data structure should look like, you can start with a very loose prompt and see what you get back. I find this a useful pattern for underspecified problems where a big part of the problem is just defining precisely what problem you want to solve. Seeing the LLM's attempt at a data structure gives me something to immediately react to, rather than having to start from a blank page.

```{python}
instruct_json = """
  You're an expert baker who also loves JSON. I am going to give you a list of
  ingredients and your job is to return nicely structured JSON. Just return the
  JSON and no other commentary.
"""
chat.system_prompt = instruct_json
_ = chat.chat(ingredients)
```

(I don't know if the colour text, "You're an expert baker who also loves JSON", does anything, but I like to think this helps the LLM get into the right mindset of a very nerdy baker.)

### Provide examples

This isn't a bad start, but I prefer to cook with weight and I only want to see volumes if weight isn't available so I provide a couple of examples of what I'm looking for. I was pleasantly suprised that I can provide the input and output examples in such a loose format.

```{python}
instruct_weight = """
  Here are some examples of the sort of output I'm looking for:

  ¾ cup (150g) dark brown sugar
  {"name": "dark brown sugar", "quantity": 150, "unit": "g"}

  ⅓ cup (80ml) neutral oil
  {"name": "neutral oil", "quantity": 80, "unit": "ml"}

  2 t ground cinnamon
  {"name": "ground cinnamon", "quantity": 2, "unit": "teaspoon"}
"""

chat.system_prompt = instruct_json + "\n" + instruct_weight
_ = chat.chat(ingredients)
```

Just providing the examples seems to work remarkably well. But I found it useful to also include description of what the examples are trying to accomplish. I'm not sure if this helps the LLM or not, but it certainly makes it easier for me to understand the organisation and check that I've covered the key pieces that I'm interested in.

```{python}
instruct_weight = """
  * If an ingredient has both weight and volume, extract only the weight:

  ¾ cup (150g) dark brown sugar
  [
    {"name": "dark brown sugar", "quantity": 150, "unit": "g"}
  ]

* If an ingredient only lists a volume, extract that.

  2 t ground cinnamon
  ⅓ cup (80ml) neutral oil
  [
    {"name": "ground cinnamon", "quantity": 2, "unit": "teaspoon"},
    {"name": "neutral oil", "quantity": 80, "unit": "ml"}
  ]
"""
```

This structure also allows me to give the LLMs a hint about how I want multiple ingredients to be stored, i.e. as an JSON array.

I then iterated on the prompt, looking at the results from different recipes to get a sense of what the LLM was getting wrong. Much of this felt like I was iterating on my understanding of the problem as I didn't start by knowing exactly how I wanted the data. For example, when I started out I didn't really think about all the various ways that ingredients are specified. For later analysis, I always want quantities to be number, even if they were originally fractions, or the if the units aren't precise (like a pinch). It made me to realise that some ingredients are unitless.

```{python}
instruct_unit = """
* If the unit uses a fraction, convert it to a decimal.

  ⅓ cup sugar
  ½ teaspoon salt
  [
    {"name": "dark brown sugar", "quantity": 0.33, "unit": "cup"},
    {"name": "salt", "quantity": 0.5, "unit": "teaspoon"}
  ]

* Quantities are always numbers

  pinch of kosher salt
  [
    {"name": "kosher salt", "quantity": 1, "unit": "pinch"}
  ]

* Some ingredients don't have a unit.
  2 eggs
  1 lime
  1 apple
  [
    {"name": "egg", "quantity": 2},
    {"name": "lime", "quantity": 1},
    {"name", "apple", "quantity": 1}
  ]
"""
```

You might want to take a look at the [full prompt](https://gist.github.com/hadley/7688b4dd1e5e97b800c6d7d79e437b48) to see what I ended up with.

### Structured data

Now that I've iterated to get a data structure that I like, it seems useful to formalise it and tell the LLM exactly what I'm looking for using [structured data](structured-data.qmd). This guarantees that the LLM will only return JSON, the JSON will have the fields that you expect, and that chatlas will convert it into an Python data structure for you.

```{python}
from pydantic import BaseModel, Field

class Ingredient(BaseModel):
    "Ingredient name"
    name: str = Field(description="Ingredient name")
    quantity: float
    unit: str | None = Field(description="Unit of measurement")

class Ingredients(BaseModel):
    items: list[Ingredient]

chat.system_prompt = instruct_json + "\n" + instruct_weight
chat.extract_data(ingredients, data_model=Ingredients)
```

### Capturing raw input

One thing that I'd do next time would also be to include the raw ingredient name in the output. This doesn't make much difference here, in this simple example, but it makes it much easier to align the input and the output and start to develop automated measures of how well my prompt is doing.

```{python}
instruct_weight_input = """
  * If an ingredient has both weight and volume, extract only the weight:

    ¾ cup (150g) dark brown sugar
    [
      {"name": "dark brown sugar", "quantity": 150, "unit": "g", "input": "¾ cup (150g) dark brown sugar"}
    ]

  * If an ingredient only lists a volume, extract that.

    2 t ground cinnamon
    ⅓ cup (80ml) neutral oil
    [
      {"name": "ground cinnamon", "quantity": 2, "unit": "teaspoon", "input": "2 t ground cinnamon"},
      {"name": "neutral oil", "quantity": 80, "unit": "ml", "input": "⅓ cup (80ml) neutral oil"}
    ]
"""
```

I think this is particularly important if you're working with even less structured text. For example, imagine you had this text:

```{python}
recipe = """
  In a large bowl, cream together one cup of softened unsalted butter and a
  quarter cup of white sugar until smooth. Beat in an egg and 1 teaspoon of
  vanilla extract. Gradually stir in 2 cups of all-purpose flour until the
  dough forms. Finally, fold in 1 cup of semisweet chocolate chips. Drop
  spoonfuls of dough onto an ungreased baking sheet and bake at 350°F (175°C)
  for 10-12 minutes, or until the edges are lightly browned. Let the cookies
  cool on the baking sheet for a few minutes before transferring to a wire
  rack to cool completely. Enjoy!
"""
```

Including the input text in the output makes it easier to see if it's doing a good job:

```{python}
chat.system_prompt = instruct_json + "\n" + instruct_weight_input
_ = chat.chat(ingredients)
```


When I ran it while writing this vignette, it seems to be working out the weight of the ingredients specified in volume, even though the prompt specifically asks it not to do that. This may suggest I need to broaden my examples.

## Token usage

```{python}
from chatlas import token_usage
token_usage()
```</prompt-design.qmd>


Here is the file structured-data.qmd for posit-dev/chatlas:
<structured-data.qmd>
# Structured data

When using an LLM to extract data from text or images, you can ask the chatbot to nicely format it, in JSON or any other format that you like. This will generally work well most of the time, but there's no gaurantee that you'll actually get the exact format that you want. In particular, if you're trying to get JSON, find that it's typically surrounded in ```` ```json ````, and you'll occassionally get text that isn't actually valid JSON. To avoid these challenges you can use a recent LLM feature: **structured data** (aka structured output). With structured data, you supply a type specification that exactly defines the object structure that you want and the LLM will guarantee that's what you get back.

```{python}
import json
import pandas as pd
from chatlas import ChatOpenAI
from pydantic import BaseModel, Field
```

## Structured data basics

To extract structured data you call the `.extract_data()` method instead of the `.chat()` method. You'll also need to define a type specification that describes the structure of the data that you want (more on that shortly). Here's a simple example that extracts two specific values from a string:

```{python}
#| warning: false
class Person(BaseModel):
    name: str
    age: int


chat = ChatOpenAI()
chat.extract_data(
  "My name is Susan and I'm 13 years old", 
  data_model=Person,
)
```

The same basic idea works with images too:

```{python}
from chatlas import content_image_url

class Image(BaseModel):
    primary_shape: str
    primary_colour: str

chat.extract_data(
  content_image_url("https://www.r-project.org/Rlogo.png"),
  data_model=Image,
)
```


## Data types basics

To define your desired type specification (also known as a **schema**), you use a [pydantic model](https://docs.pydantic.dev/latest/concepts/models/). 

In addition to the model definition with field names and types, you may also want to provide the LLM with an additional context about what each field/model represents. In this case, include a `Field(description="...")` for each field, and a docstring for each model. This is a good place to ask nicely for other attributes you'll like the value to possess (e.g. minimum or maximum values, date formats, ...). You aren't guaranteed that these requests will be honoured, but the LLM will usually make a best effort to do so.

```{python}
class Person(BaseModel):
    """A person"""

    name: str = Field(description="Name")

    age: int = Field(description="Age, in years")

    hobbies: list[str] = Field(
        description="List of hobbies. Should be exclusive and brief."
    )
```

Now we'll dive into some examples before coming back to talk more data types details.

## Examples

The following examples are [closely inspired by the Claude documentation](https://github.com/anthropics/anthropic-cookbook/blob/main/tool_use/extracting_structured_json.ipynb) and hint at some of the ways you can use structured data extraction.

### Example 1: Article summarisation

```{python}
# | warning: false
with open("examples/third-party-testing.txt") as f:
    text = f.read()


class ArticleSummary(BaseModel):
    """Summary of the article."""

    author: str = Field(description="Name of the article author")

    topics: list[str] = Field(
        description="Array of topics, e.g. ['tech', 'politics']. Should be as specific as possible, and can overlap."
    )

    summary: str = Field(description="Summary of the article. One or two paragraphs max")

    coherence: int = Field(
        description="Coherence of the article's key points, 0-100 (inclusive)"
    )

    persuasion: float = Field(
        description="Article's persuasion score, 0.0-1.0 (inclusive)"
    )


chat = ChatOpenAI()
data = chat.extract_data(text, data_model=ArticleSummary)
print(json.dumps(data, indent=2))
```

### Example 2: Named entity recognition

```{python}
# | warning: false
text = "John works at Google in New York. He met with Sarah, the CEO of Acme Inc., last week in San Francisco."


class NamedEntity(BaseModel):
    """Named entity in the text."""

    name: str = Field(description="The extracted entity name")

    type_: str = Field(description="The entity type, e.g. 'person', 'location', 'organization'")

    context: str = Field(description="The context in which the entity appears in the text.")


class NamedEntities(BaseModel):
    """Named entities in the text."""

    entities: list[NamedEntity] = Field(description="Array of named entities")


chat = ChatOpenAI()
data = chat.extract_data(text, data_model=NamedEntities)
pd.DataFrame(data["entities"])
```

### Example 3: Sentiment analysis

```{python}
#| warning: false
text = "The product was okay, but the customer service was terrible. I probably won't buy from them again."

class Sentiment(BaseModel):
    """Extract the sentiment scores of a given text. Sentiment scores should sum to 1."""

    positive_score: float = Field(
        description="Positive sentiment score, ranging from 0.0 to 1.0"
    )

    negative_score: float = Field(
        description="Negative sentiment score, ranging from 0.0 to 1.0"
    )

    neutral_score: float = Field(
        description="Neutral sentiment score, ranging from 0.0 to 1.0"
    )


chat = ChatOpenAI()
chat.extract_data(text, data_model=Sentiment)
```

Note that we've asked nicely for the scores to sum 1, and they do in this example (at least when I ran the code), but it's not guaranteed.

### Example 4: Text classification

```{python}
# | warning: false
from typing import Literal

text = "The new quantum computing breakthrough could revolutionize the tech industry."


class Classification(BaseModel):

    name: Literal[
        "Politics", "Sports", "Technology", "Entertainment", "Business", "Other"
    ] = Field(description="The category name")

    score: float = Field(description="The classification score for the category, ranging from 0.0 to 1.0.")


class Classifications(BaseModel):
    """Array of classification results. The scores should sum to 1."""

    classifications: list[Classification]


chat = ChatOpenAI()
data = chat.extract_data(text, data_model=Classifications)
pd.DataFrame(data["classifications"])
```

### Example 5: Working with unknown keys

```{python}
# | warning: false
from chatlas import ChatAnthropic


class Characteristics(BaseModel, extra="allow"):
    """All characteristics"""

    pass


prompt = """
  Given a description of a character, your task is to extract all the characteristics of that character.

  <description>
  The man is tall, with a beard and a scar on his left cheek. He has a deep voice and wears a black leather jacket.
  </description>
"""

chat = ChatAnthropic()
data = chat.extract_data(prompt, data_model=Characteristics)
print(json.dumps(data, indent=2))
```

This example only works with Claude, not GPT or Gemini, because only Claude
supports adding arbitrary additional properties.

### Example 6: Extracting data from an image

This example comes from [Dan Nguyen](https://gist.github.com/dannguyen/faaa56cebf30ad51108a9fe4f8db36d8) and you can see other interesting applications at that link. The goal is to extract structured data from this screenshot:

The goal is to extract structured data from this screenshot:

![A screenshot of schedule A: a table showing assets and "unearned" income](congressional-assets.png)

Even without any descriptions, ChatGPT does pretty well:

```{python}
# | warning: false
from chatlas import content_image_file


class Asset(BaseModel):
    assert_name: str
    owner: str
    location: str
    asset_value_low: int
    asset_value_high: int
    income_type: str
    income_low: int
    income_high: int
    tx_gt_1000: bool


class DisclosureReport(BaseModel):
    assets: list[Asset]


chat = ChatOpenAI()
data = chat.extract_data(
    content_image_file("images/congressional-assets.png"), data_model=DisclosureReport
)
pd.DataFrame(data["assets"])
```

## Advanced data types

Now that you've seen a few examples, it's time to get into more specifics about data type declarations.

### Required vs optional

By default, model fields are in a sense "required", unless `None` is allowed in their type definition. Including `None` is a good idea if there's any possibility of the input not containing the required fields as LLMs may hallucinate data in order to fulfill your spec.

For example, here the LLM hallucinates a date even though there isn't one in the text:

```{python}
# | warning: false
class ArticleSpec(BaseModel):
    """Information about an article written in markdown"""

    title: str = Field(description="Article title")
    author: str = Field(description="Name of the author")
    date: str = Field(description="Date written in YYYY-MM-DD format.")


prompt = """
  Extract data from the following text:

  <text>
  # Structured Data
  By Hadley Wickham

  When using an LLM to extract data from text or images, you can ask the chatbot to nicely format it, in JSON or any other format that you like.
  </text>
"""

chat = ChatOpenAI()
data = chat.extract_data(prompt, data_model=ArticleSpec)
print(json.dumps(data, indent=2))
```

Note that I've used more of an explict prompt here. For this example, I found that this generated better results, and it's a useful place to put additional instructions.

If let the LLM know that the fields are all optional, it'll instead return `None` for the missing fields:

```{python}
class ArticleSpec(BaseModel):
    """Information about an article written in markdown"""

    title: str = Field(description="Article title")
    author: str = Field(description="Name of the author")
    date: str | None = Field(description="Date written in YYYY-MM-DD format.")


data = chat.extract_data(prompt, data_model=ArticleSpec)
print(json.dumps(data, indent=2))
```


### Data frames

If you want to define a data frame like `data_model`, you might be tempted to create a model like this, where each field is a list of scalar values:

```python
class Persons(BaseModel):
    name: list[str]
    age: list[int]
```

This however, is not quite right because there's no way to specify that each field should have the same length. Instead you need to turn the data structure "inside out", and instead create an array of objects:

```python
class Person(BaseModel):
    name: str
    age: int

class Persons(BaseModel):
    persons: list[Person]
```

If you're familiar with the terms between row-oriented and column-oriented data frames, this is the same idea.

## Token usage

Below is a summary of the tokens used to create the output in this example. 

```{python}
#| type: asis
from chatlas import token_usage
token_usage()
```
</structured-data.qmd>


Here is the file tool-calling.qmd for posit-dev/chatlas:
<tool-calling.qmd>
## Introduction

One of the most interesting aspects of modern chat models is their ability to make use of external tools that are defined by the caller.

When making a chat request to the chat model, the caller advertises one or more tools (defined by their function name, description, and a list of expected arguments), and the chat model can choose to respond with one or more "tool calls". These tool calls are requests *from the chat model to the caller* to execute the function with the given arguments; the caller is expected to execute the functions and "return" the results by submitting another chat request with the conversation so far, plus the results. The chat model can then use those results in formulating its response, or, it may decide to make additional tool calls.

*Note that the chat model does not directly execute any external tools!* It only makes requests for the caller to execute them. It's easy to think that tool calling might work like this:

![Diagram showing showing the wrong mental model of tool calls: a user initiates a request that flows to the assistant, which then runs the code, and returns the result back to the user."](images/tool-calling-wrong.svg)

But in fact it works like this:

![Diagram showing the correct mental model for tool calls: a user sends a request that needs a tool call, the assistant request that the user's runs that tool, returns the result to the assistant, which uses it to generate the final answer.](images/tool-calling-right.svg)

The value that the chat model brings is not in helping with execution, but with knowing when it makes sense to call a tool, what values to pass as arguments, and how to use the results in formulating its response.

```{python}
from chatlas import ChatOpenAI
```

### Motivating example

Let's take a look at an example where we really need an external tool. Chat models generally do not know the current time, which makes questions like these impossible.

```{python}
chat = ChatOpenAI(model="gpt-4o")
_ = chat.chat("How long ago exactly was the moment Neil Armstrong touched down on the moon?")
```

Unfortunately, the LLM doesn't hallucinates the current date. Let's give the chat model the ability to determine the current time and try again.

### Defining a tool function

The first thing we'll do is define a Python function that returns the current time. This will be our tool.

```{python}
def get_current_time(tz: str = "UTC") -> str:
    """
    Gets the current time in the given time zone.

    Parameters
    ----------
    tz
        The time zone to get the current time in. Defaults to "UTC".

    Returns
    -------
    str
        The current time in the given time zone.
    """
    from datetime import datetime
    from zoneinfo import ZoneInfo

    return datetime.now(ZoneInfo(tz)).strftime("%Y-%m-%d %H:%M:%S %Z")
```

Note that we've gone through the trouble of adding the following to our function: 

- Type hints for arguments and the return value
- A docstring that explains what the function does and what arguments it expects

**Providing these hints and context is very important**, as it helps the chat model understand how to use your tool correctly!

Let's test it:

```{python}
get_current_time()
```


### Using the tool

In order for the LLM to make use of our tool, we need to register it with the chat object. This is done by calling the `register_tool` method on the chat object.

```{python}
chat.register_tool(get_current_time)
```

Now let's retry our original question:

```{python}
_ = chat.chat("How long ago exactly was the moment Neil Armstrong touched down on the moon?")
```

That's correct! Without any further guidance, the chat model decided to call our tool function and successfully used its result in formulating its response.

This tool example was extremely simple, but you can imagine doing much more interesting things from tool functions: calling APIs, reading from or writing to a database, kicking off a complex simulation, or even calling a complementary GenAI model (like an image generator). Or if you are using chatlas in a Shiny app, you could use tools to set reactive values, setting off a chain of reactive updates.

### Tool limitations

Remember that tool arguments come from the chat model, and tool results are returned to the chat model. That means that only simple, JSON-compatible data types can be used as inputs and outputs. It's highly recommended that you stick to basic types for each function parameter (e.g. `str`, `float`/`int`, `bool`, `None`, `list`, `tuple`, `dict`). And you can forget about using functions, classes, external pointers, and other complex (i.e., non-serializable) Python objects as arguments or return values. Returning data frames seems to work OK (as long as you return the JSON representation -- `.to_json()`), although be careful not to return too much data, as it all counts as tokens (i.e., they count against your context window limit and also cost you money).
</tool-calling.qmd>


Here is the file web-apps.qmd for posit-dev/chatlas:
<web-apps.qmd>
In the intro, we learned how the `.app()` method launches a web app with a simple chat interface, for example:

```python
from chatlas import ChatAnthropic

chat = ChatAnthropic()
chat.app()
```

This is a great way to quickly test your model, but you'll likely want to embed similar functionality into a larger web app. Here's how you can do that we different web frameworks.

## Shiny

Using Shiny's [`ui.Chat` component](https://shiny.posit.co/py/components/display-messages/chat/), you can simply pass user input from the component into the `chat.stream()` method. This generate a response stream that can then be passed to `.append_message_stream()`.

```python
from chatlas import ChatAnthropic
from shiny.express import ui

chat = ChatAnthropic()

chat_ui = ui.Chat(
    id="ui_chat",
    messages=["Hi! How can I help you today?"],
)
chat_ui.ui()


@chat_ui.on_user_submit
async def _():
    response = chat.stream(chat_ui.user_input())
    await chat_ui.append_message_stream(response)
```

## Streamlit

Coming soon
</web-apps.qmd>


Here is the file index.qmd for posit-dev/py-shiny-site:
<index.qmd>
---
title: Chat
sidebar: components
appPreview:
  file: components/display-messages/chat/app-preview.py
listing:
- id: example
  template: ../../_partials/components-detail-example.ejs
  template-params:
    dir: components/display-messages/chat/
  contents:
  - title: Preview
    file: app-preview-code.py
    height: 500
  - title: Express
    file: app-express.py
    shinylive: https://shinylive.io/py/editor/#code=NobwRAdghgtgpmAXAAjFADugdOgnmAGlQGMB7CAFzkqVQDMAnUmZAZwAsBLCXLOAD3QM4rVsk4x0pBhWQBXTgB0IyhTigBzOAH1S6CqwAUy5KeQVOFADZwAvIrAAJOFaulkAZS49kAYXZQFA4EJmZ0nK5QAEY2tgAqDHJwIRBmyOGRMTowpFERdglJKQCUysoAxH7CgXDIUMjEAbLcrBRQEMS17QAmyN2crOhWULjiQR1NyLbynFj+gYac3fZgjYEOxaaVADzbymsUWAqGm8g7eyqXlQAicOEQXQ1QrlFQxADW5u6JqQDu7NRzAD5Kw4Aw2HIojBLGJ6vBRJo4MoAAIHLDkbRyUEMbSsSHQ2RnZC7ZRQVi4Dp9O7IbQnFBEkmpMyVDwSIajOCNdwUYFYsEAcjE3HQclkrw+XyBcBgoVMUF+UEsDSaWAw6Go3W08NYiMMdAcAE1SHI2IruigQGi+TjhaKTgBfDZbYkXQioCi4dW0MBUfgUMD2gC6QA
  - title: Core
    file: app-core.py
    shinylive: https://shinylive.io/py/editor/#code=NobwRAdghgtgpmAXAAjFADugdOgnmAGlQGMB7CAFzkqVQDMAnUmZAZwAsBLCXZTmdKQYVkAQUxEArpwA6EORnQB9acgC8yaTigBzOErqcANkagAjI3AAUc5Hc2dtEOEaUVOFSzbAAJF0dJkAGUuHmQAYXYoChkwAEoCW3stYiiKFU5vVOjYhLsAYmQAHiKku0MTc0slGFIzYzg1ABUGSThEiDi5bogAEzg6NjgGADdhq250SQo4xDLkQvCGOGi4ZChkbJFuVgooCGI1-d7kXs5WdFNeD3mt9QcsSOiJ3rVYrdyC4tL5CHsF5AAEQG3COmygJjMUGIAGtkBRAq0-gB3djUeFozSsYZsSRmGAeVjrZDwVisXRweYAAS2WHIKmxDCUrDxBJEAJK8ygrFwB1OA2QSissy+nL+-3shSC-EuvDgqUCFExkkZAHIiZNpsgobD4Yq0TB5v8oMioB5NmksIpqL0anAyRSrHRYgBNUiSNhm3ooEC0lXDJSaijCgC+nw5Px6inu4nQVkUGSIjLGDC6EEIqAouHQCBQYCoAA8KGAQwBdIA
- id: relevant-functions
  template: ../../_partials/components-detail-relevant-functions.ejs
  template-params:
    dir: components/display-messages/chat
  contents:
  - title: chat = ui.Chat()
    href: https://shiny.posit.co/py/api/ui.Chat.html
    signature: ui.Chat(id, messages=(), on_error="auto", tokenizer=MISSING)
  - title: chat.ui()
    href: https://shiny.posit.co/py/api/ui.Chat.html
    signature: chat.ui(placeholder="Enter a message...", width="min(680px, 100%)",
      height = "auto", fill = True)
  - title: '@chat.on_user_submit'
    href: https://shiny.posit.co/py/api/ui.Chat.html
    signature: chat.on_user_submit(fn)
  - title: chat.messages()
    href: https://shiny.posit.co/py/api/ui.Chat.html
    signature: chat.messages(format=MISSING, token_limits=(4096, 1000), transform_user="all",
      transform_assistant=False)
  - title: chat.append_message()
    href: https://shiny.posit.co/py/api/ui.Chat.html
    signature: chat.append_message(message)
  - title: chat.append_message_stream()
    href: https://shiny.posit.co/py/api/ui.Chat.html
    signature: chat.append_message_stream(message)
---

:::{#example}
:::

:::{#relevant-functions}
:::



## Generative AI quick start {#ai-quick-start}

Pick from one of the following providers below to get started with generative AI in your Shiny app.
Once you've choosen a provider, copy/paste the `shiny create` terminal command to get the relevant source files on your machine.

::: {.panel-tabset .panel-pills}

### LangChain with OpenAI

```bash
shiny create --template chat-ai-langchain
```

### OpenAI

```bash
shiny create --template chat-ai-openai
```

### Anthropic

```bash
shiny create --template chat-ai-anthropic
```

### Google

```bash
shiny create --template chat-ai-gemini
```

### Ollama

```bash
shiny create --template chat-ai-ollama
```

### OpenAI via Azure

```bash
shiny create --template chat-ai-azure-openai
```

### Anthropic via AWS Bedrock

```bash
shiny create --template chat-ai-anthropic-aws
```

:::

Once the `app.py` file is on your machine, open it and follow the instructions at the top of the file.
These instructions should help with signing up for an account with the relevant provider, obtaining an API key, and finally get that key into your Shiny app.

Note that all these examples roughly follow the same pattern, with the only real difference being the provider-specific code for generating responses.
If we were to abstract away the provider-specific code, we're left with the pattern shown below.
Most of the time, providers will offer a `stream=True` option for generating responses, which is preferrable for more responsive and scalable chat interfaces.
Just make sure to use `.append_message_stream()` instead of `.append_message()` when using this option.

::: {.panel-tabset .panel-pills}

### Streaming

```python
from shiny.express import ui

chat = ui.Chat(id="my_chat")
chat.ui()

@chat.on_user_submit
async def _():
    messages = chat.messages()
    response = await my_model.generate_response(messages, stream=True)
    await chat.append_message_stream(response)
```

### Non-streaming

```python
from shiny.express import ui

chat = ui.Chat(id="my_chat")
chat.ui()

@chat.on_user_submit
async def _():
    messages = chat.messages()
    response = await my_model.generate_response(messages)
    await chat.append_message(response)
```
:::


::: callout-tip
### Appending is async

Appending messages to a chat is always an async operation.
This means that you should `await` the `.append_message()` or `.append_message_stream()` method when calling it and also make sure that the callback function is marked as `async`.
:::

The templates above are a great starting point for building a chat interface with generative AI.
And, out of the box, `Chat()` provides some nice things like [error handling](#error-handling) and [code highlighting](#code-highlighting).
However, to richer and bespoke experiences, you'll want to know more about things like message formats, startup messages, system messages, retrieval-augmented generation (RAG), and more.

## Message format

When calling `chat.messages()` to retrieve the current messages, you'll generally get a tuple of dictionaries following the format below.
This format also generally works when adding messages to the chat.

```python
message = {
  "content": "Message content",
  "role": "assistant" | "user" | "system", # choose one
}
```

Unfortunately, this format is not universal across providers, and so it may not be directly usable as an input to a generative AI model.
Fortunately, `chat.messages()` has a `format` argument to help with this.
That is, if you're using a provider like OpenAI, you can pass `format="openai"` to `chat.messages()` to get the proper format for generating responses with OpenAI.

Similarly, the return type of generative AI models can also be different.
Fortunately, `chat.append_message()` and `chat.append_message_stream()` "just work" with most providers, but if you're using a provider that isn't yet supported, you should be able to reshape the response object into the format above.

## Startup messages

To show message(s) when the chat interface is first loaded, you can pass a sequence of `messages` to `Chat`.
Note that, assistant messages are interpreted as markdown by default.[^html-responses]

[^html-responses]: The interpretation and display of assistant messages [can be customized](#custom-response-display).

```python
message = {
  "content": "**Hello!** How can I help you today?",
  "role": "assistant"
}
chat = ui.Chat(id="chat", messages=[message])
chat.ui()
```

![](/images/chat-hello.png)

In addition to providing instructions or a welcome message, you can also use this feature to provide system message(s).


## System messages

Different providers have different ways of working with system messages.
If you're using a provider like OpenAI, you can have message(s) with a `role` of `system`.
However, other providers (e.g., Anthropic) may want the system message to be provided in to the `.generate_response()` method.
To help standardize how system messages interact with `Chat`, we recommending to using [LangChain's chat models](https://python.langchain.com/v0.1/docs/modules/model_io/chat/quick_start/).
This way, you can just pass system message(s) on startup (just like you would with a provider like OpenAI):

```python
system_message = {
  "content": "You are a helpful assistant",
  "role": "system"
}
chat = ui.Chat(id="chat", messages=[system_message])
```

Just make sure, when using LangChain, to use `format="langchain"` to get the proper format for generating responses with LangChain.

```python
@chat.on_user_submit
async def _():
    messages = chat.messages(format="langchain")
    response = await my_model.astream(messages)
    await chat.append_message_stream(response)
```

Remember that you can get a full working template in the [Generative AI quick start](#ai-quick-start) section above.
Also, for another more advanced example of dynamic system messages, check out this example:

```bash
shiny create --github posit-dev/py-shiny:examples/chat/playground
```

## Message trimming

When the conservation gets becomes excessively long, it's often desirable to discard "old" messages to prevent errors and/or costly response generation.
To help with this, `chat.messages()` only keeps the most recent messages that fit within a conservative `token_limit`.
See [the documentation](https://shiny.posit.co/py/api/ui.Chat.html) for more information on how to adjust this limit. Note that trimming can be disabled by setting `.messages(token_limit=None)` or `Chat(tokenizer=None)`.


## Error handling {#error-handling}

When errors occur in the `@on_user_submit` callback, the app displays a dismissible notification about the error.
When running locally, the actual error message is shown, but in production, only a generic message is shown (i.e., the error is sanitized since it may contain sensitive information).
If you'd prefer to have errors stop the app, that can also be done through the `on_error` argument of `Chat` (see [the documentation](https://shiny.posit.co/py/api/ui.Chat.html) for more information).

![](/images/chat-error.png){class="rounded shadow"}

## Code highlighting {#code-highlight}

When a message response includes code, it'll be syntax highlighted (via [highlight.js](https://highlightjs.org/)) and also include a copy button.

![](/images/chat-code.png){class="rounded shadow"}

## Custom response display

By default, message strings are interpreted as (github-flavored) markdown.
To customize how assistant responses are interpreted and displayed, define a `@chat.transform_assistant_response` function that returns `ui.HTML`.
For a basic example, you could use `ui.markdown()` to customize the markdown rendering:

```python
chat = ui.Chat(id="chat")

@chat.transform_assistant_response
def _(content: str) -> ui.HTML:
    return ui.markdown(content)
```

::: callout-tip
### Streaming transformations

When streaming, the transform is called on each iteration of the stream, and gets passed the accumulated `content` of the message received thus far.
For more complex transformations, you might want access to each chunk and a signal of whether the stream is done.
See the [the documentation](https://shiny.posit.co/py/api/ui.Chat.html) for more information.
:::


::: callout-tip
### `chat.messages()` defaults to `transform_assistant=False`

By default, `chat.messages()` doesn't apply `transform_assistant_response` to the messages it returns.
This is because the messages are intended to be used as input to the generative AI model, and so should be in a format that the model expects, not in a format that the UI expects.
So, although you _can_ do `chat.messages(transform_assistant=True)`, what you might actually want to do is "post-process" the response from the model before appending it to the chat.
:::


## Transforming user input

Transforming user input before passing it to a generative AI model is a fundamental part of more advanced techniques like retrieval-augmented generation (RAG).
An overly basic transform might just prepend a message to the user input before passing it to the model.

```python
chat = ui.Chat(id="chat")

@chat.transform_user_input
def _(input: str) -> str:
    return f"Translate this to French: {input}"
```

A more compelling transform would be to allow the user to enter a URL to a website, and then pass the content of that website to the LLM along with [some instructions](#system-messages) on how to summarize or extract information from it.
For a concrete example, this template allows you to enter a URL to a website that contains a recipe, and then the assistant will extract the ingredients and instructions from that recipe in a structured format:

```bash
shiny create --github posit-dev/py-shiny:examples/chat/RAG/recipes
```

![](/images/chat-recipes.mp4){class="rounded shadow"}

In addition to providing a helpful startup message, the app above also improves UX by gracefully handling errors that happen in the transform.
That is, when an error occurs, it appends a useful message to the chat and returns `None` from the transform.

```python
@chat.transform_user_input
async def try_scrape_page(input: str) -> str | None:
    try:
        return await scrape_page_with_url(input)
    except Exception:
        await chat.append_message(
            "I'm sorry, I couldn't extract content from that URL. Please try again. "
        )
        return None
```


The default behavior of `chat.messages()` is to apply `transform_user_input` to every user message (i.e., it defaults to `transform_user="all"`).
In some cases, like the recipes app above, the LLM doesn't need _every_ user message to be transformed, just the last one.
In these cases, you can use `chat.messages(transform_user="last")` to only apply the transform to the last user message (or simply `chat.user_input()` if the model only needs the most recent user message).
</index.qmd>


Here is the file app-express.py for posit-dev/py-shiny-site:
<app-express.py>
from shiny.express import ui

ui.page_opts(
    title="Hello Shiny Chat",
    fillable=True,
    fillable_mobile=True,
)

# Create a chat instance and display it
chat = ui.Chat(id="chat")  # <<
chat.ui()  # <<


# Define a callback to run when the user submits a message
@chat.on_user_submit  # <<
async def _():  # <<
    # Simply echo the user's input back to them
    await chat.append_message(f"You said: {chat.user_input()}")  # <<
</app-express.py>

