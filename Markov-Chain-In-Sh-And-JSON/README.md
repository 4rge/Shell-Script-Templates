# Markov Chain Text Generator

## Overview

This Bash script implements a Markov Chain text generation model. It allows users to train the model on phrases or text files and generate new text based on the trained model. It utilizes the `jq` tool for JSON manipulation and the `dict` command for part-of-speech classification.

## Features

- Check for dependencies (`jq` and `dict`) and prompt installation if missing.
- Train the model using user input or text files.
- Generate random sentences based on the trained model.
- Sanitize and classify input words.
- Remove duplicates from sentences.
- User feedback for improving generated sentences.
- Keeps track of punctuation based on generated sentences.

## Dependencies

Before running this script, ensure that you have the following installed:

- **`jq`**: A lightweight and flexible command-line JSON processor.
- **`dict`**: A command-line interface to retrieve definitions from online dictionaries.

## Menu Options:

Upon running, you'll be presented with a menu:

1: Train the model with new phrases.

2: Generate a sequence with the trained model.

3: Train the model from one or more text files.

4: Exit the script.

## Training:

To train the model, select option 1 and input phrases. Type exit when done.
Alternatively, select option 3 to train from text files. You can specify multiple file paths (space-separated).

## Generate Text:

After training, select option 2 to generate sentences. You'll be prompted to specify how many sentences to generate.

## Feedback Loop:

After generating sentences, you can provide numbers of sentences that you believe are not satisfactory. You can then propose better sentences for the model to learn from.

## JSON Structure

The model saves the trained data in a JSON file named markov_chain.json. The structure is as follows:
```
{
  "states": {
    "phrase1": ["phrase2", "phrase3"],
    "phrase2": ["phrase4"],
    ...
  }
}
