A chatbot that can answer questions about the Python packages [chatlas](https://github.com/posit-dev/chatlas) and [Shiny](https://github.com/posit-dev/py-shiny). It's implemented by simply stuffing the README.md files from both projects into a system prompt for GPT-4o.

## Live app

[https://gallery.shinyapps.io/chatlas-assistant/](https://gallery.shinyapps.io/chatlas-assistant/)

## Installation

```r
pip install -r requirements.txt
```

You must also create a .env file containing your OpenAI API key:

```
OPENAI_API_KEY=your-api-key
```

## Starting the app

```r
shiny run app.py
```

## License

[CC0](https://creativecommons.org/public-domain/cc0/)
