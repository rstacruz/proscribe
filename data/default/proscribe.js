$(function () {
  $("pre").each(function() {
    var $this = $(this);
    // Yeah
    if ($this.text().match(/^\s*# \[literate\][\r\n]+/)) {
      var text = $this.text();
      text = text.replace(/^\s*# \[literate\][\r\n]+/, '');

      var lines = text.split('\n');
      var sections = [];
      var current = {};
      var isNew = true;

      for (i in lines) {
        var line = lines[i] + "\n";
        var isComment = line.match(/^#/);

        if ((isNew) && (isComment)) {
          current = { top: null, comments: '', code: '' };
          sections.push(current);
          isNew = false;
        }

        if (isComment) {
          if (!current.top) {
            current.top = line.replace(/^#\s*/, '');
          } else {
            current.comments += line.replace(/^#\s*/, '');
          }
        } else {
          current.code += line;
          isNew = true;
        }
      }

      $this.html(text);

      var $code = $("<div>");
      for (i in sections) {
        var section = sections[i];
        var $el = $("<section class='literate'>");
        $el.append($("<pre>").text(section.code.replace(/^\s*|\s*$/g, '')));
        $el.append($("<h4>").text(section.top));
        $el.append($("<p>").text(section.comments));
        $code.append($el);
      }

      $this.after($code);
      $this.remove();
    }
  });

  $("pre").each(function() {
    var $this = $(this);
    $this.addClass('prettyprint');

    // Filename
    var r = /\[(.*?)\s*\((.*?)\)\]\n*/;
    var m = $this.text().match(r);
    if (m) {
      var file = m[1];
      var type = m[2];
      $this.addClass('lang-'+type);

      if (file.length) {
        $this.addClass('has-caption');
        $this.prepend($("<h5 class='caption'>").text(file));
      }

      $this.html($this.html().replace(r, ''));
    }

    // Terminal
    if ($this.text().match(/^\s*([a-zA-Z_~\/]*)\$ /)) {
      $this.addClass('terminal');
      $this.removeClass('prettyprint');
      $this.html($this.html().replace(/([a-zA-Z_~\/]*\$ )(.*?)[\r\n$]/g, "<strong><em>$1</em>$2</strong>\n"));
    }
  });

  prettyPrint();
});

