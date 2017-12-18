---
title: Filter Example on Booklist
---
# Filter Examples

Reference data found in `_data/books.yml`

## Books I have read

Loop over books and present only records in which `read` is `true`
(YAML accepts `yes` as the Boolean truth).

{% for book in site.data.books %}
{% if book.read == true %}
* [{{book.author}}, {{book.title}}]({{ book.title | datapage_url: 'all-books' }})
{% endif %}
{% endfor %}


## Books I have not read

Loop over books and present only records in which `read` is `false`.

{% for book in site.data.books %}
{% if book.read == false %}
* [{{book.author}}, {{book.title}}]({{ book.title | datapage_url: 'all-books' }})
{% endif %}
{% endfor %}
