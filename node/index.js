const getPixels = require('get-pixels');
const jsonfile = require('jsonfile');

var args = process.argv.slice(2);

if (args.length < 5) {
  console.log('Error, path, xOffset, yOffset, pixel size, spacing are required.');
  process.exit(0);
}

const filename = args[0];
const xOffset = parseInt(args[1]);
const yOffset = parseInt(args[2]);
const pSize = parseInt(args[3]);
const spacing = parseInt(args[4]);

function rgbToHex(R, G, B) {
  return '#' + toHex(R) + toHex(G) + toHex(B);
}

function toHex(n) {
  n = parseInt(n, 10);

  if (isNaN(n)) {
    return '00';
  }

  n = Math.max(0, Math.min(n, 255));

  return '0123456789ABCDEF'.charAt((n - n % 16) / 16) + '0123456789ABCDEF'.charAt(n % 16);
}

getPixels(filename, function (err, pixels) {
    if (err) {
      console.log('File error');
      process.exit(0);
    }

    const width = pixels.shape[0];
    const height = pixels.shape[1];

    var result = [];
    var colors = [];
    var matrix = [];

    var i = (xOffset * 2) - spacing;
    var horizontalElements = 0;
    var verticalElements = 0;

    while (i < width) {
      horizontalElements++;
      i += pSize + spacing;
    }

    i = 0;

    while (i < height) {
      verticalElements++;
      i += pSize + spacing;
    }

    for (var pixel = 0; pixel < (pixels.size / 4); pixel++) {
      var i = pixel * 4;
      var pIndex = i / 4;

      var y = Math.floor((i / 4) / width);
      var x = pIndex - (y * width);

      if (x < xOffset || y < yOffset || y >= height - yOffset || x >= width - xOffset) {
        continue;
      }

      var hex = rgbToHex(pixels.data[i], pixels.data[i + 1], pixels.data[i + 2]);

      if (colors.indexOf(hex) == -1) {
        colors.push(hex);
      }

      result.push(colors.indexOf(hex));

      if (x + (spacing + pSize - 1) >= width) {
        pixel += width * (spacing + pSize - 1);
      }

      pixel += spacing + pSize - 1;
    }

    var data = result.reduce(function(rows, key, index) {
      return (index % horizontalElements == 0 ? rows.push([key])
      : rows[rows.length - 1].push(key)) && rows;
    }, []);

    var frequence = {};

    for (i = 0; i < data.length; ++i) {
	     for (var j = 0; j < data[i].length; ++j) {
	        frequence[data[i][j]] = (frequence[data[i][j]] || 0) + 1;
        }
    }

    var o = {
      width: horizontalElements,
      height: verticalElements,
      colors: colors,
      amountOfColors: colors.length,
      frequence: frequence,
      data: data
    };

    jsonfile.writeFile('data.json', o, function(err) {
      if (err) {
        console.error(err);
        process.exit(0);
      }

      console.log('File written');
    });

    // console.log('HorizontalElements:', horizontalElements);
    // console.log('VerticalElements:', verticalElements);
    // console.log('Colors:', colors);
    // console.log('Data:', result.reduce(function (rows, key, index) {
    //   return (index % horizontalElements == 0 ? rows.push([key])
    //   : rows[rows.length - 1].push(key)) && rows;
    // }, []));
  });
