# Bug fix for json/text in Whitebit response:

2d1
< from aiohttp.client_exceptions import ContentTypeError
59,73c58,59
<         #response_json = await response.json()
<         #return response_json
<         try:
<             # First, try to parse the response as JSON
<             response_json = await response.json()
<             return response_json
<         except ContentTypeError:
<             # If parsing as JSON fails, return the response as plain text
<             response_text = await response.text()
<             response_json = json.loads(response_text)
<             return response_json
<         except json.JSONDecodeError:
<             # Handle the case where the response is not valid JSON
<             response_text = await response.text()
<             return response_text
---
>         response_json = await response.json()
>         return response_json
91a78
> 
