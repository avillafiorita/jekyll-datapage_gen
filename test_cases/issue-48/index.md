---
title: Issue 48
---
# {{page.title}}

Reference data found in `_data/books.yml`

{% for book in site.data.books %}
* [{{book.author}}, {{book.title}}]({{ book.NORM_name | datapage_url: 'all-books' }})
{% endfor %}

