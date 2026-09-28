___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Client ID Cookie Writer",
  "description": "Writes the Google Analytics / Server-Managed Client ID (derived from Event Data or the HttpOnly FPID cookie) into a JavaScript-accessible (non-HttpOnly) browser cookie.",
  "containerContexts": [
    "SERVER"
  ],
  "brand": {
    "displayName": "TRKKN",
    "id": "brand_custom_template"
  }
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "cookieName",
    "displayName": "Cookie Name",
    "defaultValue": "_sstreal",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Name of the browser cookie to set. Defaults to \u0027_sstreal."
  },
  {
    "type": "TEXT",
    "name": "expiration",
    "displayName": "Expiration (seconds)",
    "defaultValue": 31536000,
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^$|^\\d+$"
        ],
        "errorMessage": "The value must be empty, 0, or a positive integer."
      }
    ],
    "valueUnit": "seconds",
    "help": "Cookie lifetime in seconds. Default is 31536000 (1 year). Set to 0 to delete the cookie."
  },
  {
    "type": "TEXT",
    "name": "domain",
    "displayName": "Domain",
    "defaultValue": "auto",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Domain on which to set the cookie. \u0027auto\u0027 writes to the highest possible level in the domain hierarchy (eTLD+1)."
  },
  {
    "type": "TEXT",
    "name": "path",
    "displayName": "Path",
    "defaultValue": "/",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "sameSite",
    "displayName": "SameSite",
    "defaultValue": "lax",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "lax",
        "displayValue": "lax"
      },
      {
        "value": "strict",
        "displayValue": "strict"
      },
      {
        "value": "none",
        "displayValue": "none"
      }
    ],
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const setCookie = require("setCookie");
const getEventData = require("getEventData");
const getCookieValues = require("getCookieValues");
const decodeUriComponent = require("decodeUriComponent");

let clientId = getEventData("client_id");

//FPID cookie fallback
if (!clientId) {
  const fpidCookies = getCookieValues("FPID");
  if (fpidCookies && fpidCookies.length > 0) {
    clientId = parseFpidCookie(fpidCookies[0]);
  }
}
// Only proceed with setting cookies if Client ID is present
if (!clientId) {
  data.gtmOnFailure();
  return;
}


const cookieName = data.cookieName || "_sstreal";
const cookieOptions = buildCookieOptions(
  data.domain,
  data.expiration,
  data.sameSite,
  data.path
);

setCookie(cookieName, clientId, cookieOptions);
data.gtmOnSuccess();

// Helper to parse raw FPID cookie value into client_id
// FPID formats typically:
// FPID2.4.<url_encoded_id>.<timestamp> or FPID2.2.<id>.<timestamp>
function parseFpidCookie(rawFpid) {
  if (!rawFpid) return undefined;
  const parts = rawFpid.split(".");
  if (parts.length >= 4 && parts[0].indexOf("FPID") === 0) {
    const timestamp = parts[parts.length - 1];
    const encodedId = parts.slice(2, parts.length - 1).join(".");
    const decodedId = decodeUriComponent(encodedId) || encodedId;
    return decodedId + "." + timestamp;
  }
  if (parts.length === 3 && parts[0].indexOf("FPID") === 0) {
    const encodedId = parts.slice(1).join(".");
    return decodeUriComponent(encodedId) || encodedId;
  }
  return rawFpid;
}

function buildCookieOptions(domain, expiration, sameSite, path) {
  const options = {
    domain: domain || "auto",
    path: path || "/",
    secure: true,
    sameSite: sameSite || "lax",
    "max-age": expiration || "31536000", // one year
    httpOnly: false,
  };

  return options;
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Writes the cookie using the Client ID from Event Data
  code: |-
    mock('getEventData', (key) => {
      if (key === 'client_id') return '123456789.1716821491';
      return undefined;
    });

    let setCookieCalled = false;
    let cookieName = '';
    let cookieValue = '';

    mock('setCookie', (name, value) => {
      setCookieCalled = true;
      cookieName = name;
      cookieValue = value;
    });

    runCode({
      cookieName: '_sstreal',
      expiration: '31536000',
      domain: 'auto',
      path: '/',
      sameSite: 'lax'
    });

    assertThat(setCookieCalled).isTrue();
    assertThat(cookieName).isEqualTo('_sstreal');
    assertThat(cookieValue).isEqualTo('123456789.1716821491');
- name: Applies the configured domain, path, expiration and sameSite to the cookie
    options
  code: |-
    mock('getEventData', (key) => {
      if (key === 'client_id') return '123456789.1716821491';
      return undefined;
    });

    let cookieOptions = {};
    mock('setCookie', (name, value, options) => {
      cookieOptions = options;
    });

    runCode({
      cookieName: '_sstreal',
      expiration: '600',
      domain: 'example.com',
      path: '/custom',
      sameSite: 'strict'
    });

    assertThat(cookieOptions.domain).isEqualTo('example.com');
    assertThat(cookieOptions.path).isEqualTo('/custom');
    assertThat(cookieOptions.sameSite).isEqualTo('strict');
    assertThat(cookieOptions['max-age']).isEqualTo('600');
    assertThat(cookieOptions.secure).isTrue();
    assertThat(cookieOptions.httpOnly).isFalse();
- name: Falls back to the FPID cookie when Event Data has no client_id
  code: |-
    mock('getEventData', () => undefined);
    mock('getCookieValues', (name) => {
      if (name === 'FPID') return ['FPID2.4.abc123def456%3D.1716821491'];
      return [];
    });
    mock('decodeUriComponent', (str) => {
      return str.replace('%3D', '=');
    });

    let setCookieCalled = false;
    let cookieValue = '';

    mock('setCookie', (name, value) => {
      setCookieCalled = true;
      cookieValue = value;
    });

    runCode({
      cookieName: '_sstreal'
    });

    assertThat(setCookieCalled).isTrue();
    assertThat(cookieValue).isEqualTo('abc123def456=.1716821491');
- name: Calls gtmOnFailure and does not set a cookie when no Client ID is available
  code: |-
    mock('getEventData', () => undefined);
    mock('getCookieValues', () => []);

    let setCookieCalled = false;
    mock('setCookie', () => {
      setCookieCalled = true;
    });

    runCode({
      cookieName: '_sstreal'
    });

    assertThat(setCookieCalled).isFalse();


___NOTES___

Created on 28/09/2026
Enhanced to extract Client ID from Server-side Event Data or HttpOnly FPID cookie and write to a JavaScript-readable cookie.


