#!/bin/bash
# Extract links with labels from email MIME message, select with fzf, open in browser

URL=$(python3 -c "
import sys, email, html.parser
from email import policy

class LinkExtractor(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.current_href = None
        self.current_text = ''

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for attr, val in attrs:
                if attr == 'href' and val and val.startswith('http'):
                    self.current_href = val
                    self.current_text = ''

    def handle_data(self, data):
        if self.current_href is not None:
            self.current_text += data.strip()

    def handle_endtag(self, tag):
        if tag == 'a' and self.current_href:
            label = ' '.join(self.current_text.split()) or '(no text)'
            self.links.append((label, self.current_href))
            self.current_href = None
            self.current_text = ''

msg = email.message_from_bytes(sys.stdin.buffer.read(), policy=policy.default)

html_body = ''
if msg.is_multipart():
    for part in msg.walk():
        if part.get_content_type() == 'text/html':
            html_body = part.get_content()
            break
elif msg.get_content_type() == 'text/html':
    html_body = msg.get_content()

if not html_body:
    body = msg.get_body(preferencelist=('plain',))
    if body:
        import re
        for url in re.findall(r'https?://[^\s<>\"]+', body.get_content()):
            print(f'(no text)\t{url}')
    sys.exit(0)

p = LinkExtractor()
p.feed(html_body)
seen = set()
for label, url in p.links:
    if url not in seen:
        seen.add(url)
        if len(label) > 60:
            label = label[:57] + '...'
        print(f'{label}\t{url}')
" | fzf --ansi --prompt="Open link: " --reverse --delimiter='\t' \
    --with-nth=1 --preview='echo {2}' --preview-window=down:1)

# Extract URL (second tab-delimited field)
LINK=$(echo "$URL" | cut -f2)
if [ -n "$LINK" ]; then
    open "$LINK"
fi
