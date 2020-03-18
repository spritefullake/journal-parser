# journal-parser
## What is this?
A journal parser for my daily journal
## How to use this?
Ensure the following:
1. [NodeJS](https://nodejs.org/en/ "NodeJS installation") installed with a package manager of your choice (ex. NPM, Yarn)
2. [Python3](https://www.python.org/downloads/ "Python downloads") installed. Optionally have [anaconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/ "Anaconda installation") as a package manager (recommended).
3. [Raku and Rakudo and zef](https://raku.org/downloads/ "Raku, Rakudo and zef download") installed 
4. Ensure all of the above are located in PATH
5. Have a secrets/combined.json with the necessary google docs credentials, token and the document ID
###### Download dependencies
If you have conda, install the python packages by running:
```
conda env create -f environment.yml
```
Then for the javascript dependencies, run
```
npm install 
```
Then just run **npm start** or **npm run start** to run the fetching, transformation and analysis of the journal data.