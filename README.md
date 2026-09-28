# Client ID Cookie Writer

A **server-side Google Tag Manager (sGTM)** tag template that resolves a client/user identifier and writes it into a **JavaScript-readable (non-`HttpOnly`) browser cookie**.

It is built for setups where the browser-side page needs to read the same Client ID that the server-side container is using internally — for example, to keep a personalization script, a consent tool, or a downstream marketing pixel in sync with the ID that server-side GA4/GTM is tracking.

## What it does

On each tag execution, the template resolves a Client ID using the following fallback chain:

1. **Event Data** — reads the `client_id` field from the incoming event (the value sGTM's clients normally populate from the GA4/Measurement Protocol payload).
2. **`FPID` cookie fallback** — if Event Data has no `client_id`, the template reads the `HttpOnly` `FPID` cookie (as set by the [First-Party Identifier / FPID solution](https://www.simoahava.com/analytics/first-party-identifier-fpid-cookie/)) and parses the ID out of it.
3. **Failure** — if neither source yields an ID, the tag calls `gtmOnFailure()` and no cookie is written.

Once a Client ID is resolved, the template writes it — unmodified — into a new cookie using the [`setCookie`](https://developers.google.com/tag-platform/tag-manager/server-side/api#setcookie) server-side API, with `HttpOnly` always set to `false` so client-side JavaScript can read it.

### FPID parsing

The `FPID` cookie is expected in one of the formats written by the FPID template:

| Format      | Example                                | Parsed result              |
| ----------- | -------------------------------------- | -------------------------- |
| 4+ segments | `FPID2.4.<url_encoded_id>.<timestamp>` | `<decoded_id>.<timestamp>` |
| 3 segments  | `FPID2.2.<url_encoded_id>`             | `<decoded_id>`             |

The encoded ID segment is passed through `decodeUriComponent`; if decoding fails, the raw (still-encoded) value is used instead so the tag never throws.

## Parameters

| Field                    | Type                               | Default             | Description                                                                                                       |
| ------------------------ | ---------------------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Cookie Name**          | Text                               | `_sstreal`          | Name of the browser cookie to write.                                                                              |
| **Expiration (seconds)** | Text                               | `31536000` (1 year) | Cookie lifetime in seconds. Must be empty or a non-negative integer. Set to `0` to expire the cookie immediately. |
| **Domain**               | Text                               | `auto`              | Domain the cookie is written to. `auto` lets the server container write to the broadest allowed domain (eTLD+1).  |
| **Path**                 | Text                               | `/`                 | Cookie path.                                                                                                      |
| **SameSite**             | Select (`lax` / `strict` / `none`) | `lax`               | `SameSite` attribute for the cookie.                                                                              |

The cookie is always written with `Secure=true` and `HttpOnly=false` — this template exists specifically to expose the Client ID to client-side JavaScript, so these two attributes are not configurable.

## Required permissions

The template requests the following server-side permissions, all scoped as broadly as `any`/`*` so it can be reused across containers with different Event Data shapes, cookie names, and domains:

- **Read Event Data** — to read the `client_id` field.
- **Get Cookies** — to read the `FPID` cookie for the fallback path.
- **Set Cookies** — to write the resolved-ID cookie under any name/domain/path.

Review and, if desired, narrow these permissions to your specific values when installing the template in a container.

## Installation

1. In your **server-side** GTM container, go to **Templates → Tag Templates → New**, then **Import** this `template.tpl` file (or install it directly from the Community Template Gallery once published).
2. Accept/adjust the requested permissions.
3. Create a new tag from the template, configure the fields above, and set it to fire on the events where you want the cookie written (typically alongside your GA4/Measurement Protocol client or tag).

## Testing

The template ships with a test suite (visible under the **Tests** tab in the GTM template editor) covering:

- Writing the cookie from an Event Data `client_id`.
- Applying custom domain/path/expiration/`SameSite` values to the resulting cookie options.
- Falling back to parsing the `FPID` cookie when Event Data has no `client_id`.
- Calling `gtmOnFailure()` (and skipping `setCookie`) when no Client ID can be resolved.

Run these from the template editor's **Tests** tab before publishing any changes.

## License

Licensed under the [Apache License 2.0](LICENSE).
