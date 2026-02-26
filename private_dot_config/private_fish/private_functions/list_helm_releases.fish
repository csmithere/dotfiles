function list_helm_releases
    set -l target_url "https://storage.googleapis.com/bigid-helm/"
    
    # Flattened Python command to avoid IndentationError
    curl -s "$target_url" | python3 -c "import sys, xml.etree.ElementTree as ET; ns={'ns': 'http://doc.s3.amazonaws.com/2006-03-01'}; root=ET.parse(sys.stdin).getroot(); print('Image-Name|Date'); [print(f\"{c.find('ns:Key', ns).text}|{c.find('ns:LastModified', ns).text}\") for c in root.findall('ns:Contents', ns)]" | column -t -s "|"
end
