const fs = require('fs');
const readline = require('readline');
const { google } = require('googleapis');

// If modifying these scopes, delete token.json.
const SCOPES = ['https://www.googleapis.com/auth/documents.readonly'];
// The file token.json stores the user's access and refresh tokens, and is
// created automatically when the authorization flow completes for the first
// time.
const JOURNAL_PATH = "out/Journal.txt";
const COMBINED_PATH = "secrets/combined.json"

// Load client secrets from a local file.
fs.readFile(COMBINED_PATH, (err, content) => {
  if (err) return console.log('Error loading client secret file:', err);
  // Authorize a client with credentials, then call the Google Docs API.
  let { credentials, token, secrets } = JSON.parse(content)
  authorize(credentials, token, async auth => {
    await printDocTitle(auth, JOURNAL_PATH, secrets).catch(err => {
      throw `Caught an error: ${err}`
    })
  });
});
/**
 * Create an OAuth2 client with the given credentials, and then execute the
 * given callback function.
 * @param {Object} credentials The authorization client credentials.
 * @param {function} callback The callback to call with the authorized client.
 */
function authorize(credentials, token, callback) {
  const { client_secret, client_id, redirect_uris } = credentials.installed;
  const oAuth2Client = new google.auth.OAuth2(
    client_id, client_secret, redirect_uris[0]);

  // Check if we have previously stored a token.
  if (!token) {
    return getNewToken(oAuth2Client, callback);
  }
  else {
    oAuth2Client.setCredentials(token);
    callback(oAuth2Client);
  }

}

/**
 * Get and store new token after prompting for user authorization, and then
 * execute the given callback with the authorized OAuth2 client.
 * @param {google.auth.OAuth2} oAuth2Client The OAuth2 client to get token for.
 * @param {getEventsCallback} callback The callback for the authorized client.
 */
function getNewToken(oAuth2Client, callback) {
  const authUrl = oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
  });
  console.log('Authorize this app by visiting this url:', authUrl);
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  rl.question('Enter the code from that page here: ', (code) => {
    rl.close();
    oAuth2Client.getToken(code, (err, token) => {
      if (err) return console.error('Error retrieving access token', err);
      oAuth2Client.setCredentials(token);

      fs.readFile(COMBINED_PATH, (err, content) => {
        if (err) return console.log('Error loading combined file:', err);
        combined = JSON.parse(content);
        combined["token"] = token;
        // Store the token to disk for later program executions
        fs.writeFile(COMBINED_PATH, JSON.stringify(combined), (err) => {
          if (err) console.error(err);
          console.log('Token stored to', COMBINED_PATH);
        });
        callback(oAuth2Client);
      })

    });
  });
}


/**
 * Prints the title of a sample doc:
 * https://docs.google.com/document/d/195j9eDD3ccgjQRttHhJPymLJUCOUjs-jmwTrekvdjFE/edit
 * @param {google.auth.OAuth2} auth The authenticated Google OAuth 2.0 client.
 */

async function printDocTitle(auth, writeToPath, secrets) {
  const docs = google.docs({ version: 'v1', auth });
  const { documentId } = secrets
  let res;
  try {
    res = await docs.documents.get({ documentId })
  }
  catch (err) {
    console.log(`There was an error getting the document response: ${err}`)
  }
  let contents = res.data.body.content;
  let fullText = docsToFullText(contents);
  console.log(fullText);
  fs.writeFileSync(writeToPath, fullText)
 
}

function docsToFullText(content) {
  return content
    .reduce((acc, i) => {
      //reduce can take place of a filter + map
      if (i.paragraph && i.paragraph.elements) {
        acc.push(i.paragraph.elements)
      }
      return acc
    }, [])
    .reduce((acc, elems) => acc.concat(elems), [])
    .reduce((acc, elem) => {
      if (elem.textRun && elem.textRun.content) {
        acc += (elem.textRun.content)
      }
      return acc
    }, "");
     /* More imperative version of fetching all text
    body.map(o => {
      if(o.paragraph && o.paragraph.elements){
          o.paragraph.elements.map(e => {
            if(e.textRun && e.textRun.content){
                console.log(e.textRun.content)
            }
          })
      }
    })
   */
}
