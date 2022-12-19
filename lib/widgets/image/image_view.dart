// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/image/image_model.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:fml/helper/helper_barrel.dart';

enum ImageType {data, blob, file, svg, asset, web}

/// [IMAGE] view
class ImageView extends StatefulWidget
{
  final ImageModel model;

  ImageView(this.model) : super(key: ObjectKey(model));

  @override
  _ImageViewState createState() => _ImageViewState();

  /// Fade in Image Placeholder for network images
  static Uint8List? _placeholderImage;
  static Uint8List get placeholderImage
  {
    if (_placeholderImage == null) _placeholderImage = Base64Codec().decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGP6LwkAAiABG+faPgsAAAAASUVORK5CYII=");
    return _placeholderImage!;
  }

  /// Get an image widget from any image type
  static dynamic getImage(String? url,
      {
        Scope?  scope,
        String? defaultvalue,
        double? width,
        double? height,
        String? fit,
        String? filter,
        bool   fade: true,
        int?    fadeDuration
      })
  {
    Widget image;
    try
    {
      if (!S.isNullOrEmpty(url))
      {
        // error handler
        Widget errorHandler(BuildContext content, Object object, StackTrace? stacktrace)
        {
          if (defaultvalue != null)
          {
            if (defaultvalue.toString().toLowerCase() == 'none' || defaultvalue.toString().toLowerCase() == '') return Container();
            else return getImage(defaultvalue, defaultvalue: null, fit: fit, width: width, height: height, filter: filter, fade: fade, fadeDuration: fadeDuration);
          }
          else return Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey);
        }

        ImageType type;
              if (url!.startsWith("data:"))  type = ImageType.data;
        else if (url.startsWith("blob:"))  type = ImageType.blob;
        else if (url.startsWith("file:"))  type = ImageType.file;
        else if (url.startsWith("asset:")) type = ImageType.asset;
        else if (url.split('?')[0].endsWith('.svg')) type = ImageType.svg;
        else if (!isWeb && Url.path(url) != null && System().fileExists(Url.path(url)!)) type = ImageType.asset;
        else type = ImageType.web;

        switch (type)
        {
          /// data uri
          case ImageType.data:
            image = getByteImage(S.toDataUri(url)!.contentAsBytes(), getFit(fit), width, height, fadeDuration, errorHandler);
            break;

          /// blob image from camera or file picker
          case ImageType.blob:
            image = kIsWeb ? Image.network(url) : Image.file(File(url));
            break;

          /// file image from camera or file picker
          case ImageType.file:
            image = Image.file(File(url.replaceFirst("file:", "")));
            break;

          /// svg picture from web
          case ImageType.svg:
            image = getSvgImage(Url.toAbsolute(url), getFit(fit), width, height, errorHandler);
            break;

          /// asset image
          case ImageType.asset:
            String? filename = Url.path(url);
            image = getAssetImage(filename, getFit(fit), width, height, fadeDuration, errorHandler);
            break;

          /// web image
          case ImageType.web:
            image = getWebImage(Url.toAbsolute(url), getFit(fit), width, height, fadeDuration, errorHandler);
            break;

          /// default to:  web image
          default:
            image = getWebImage(Url.toAbsolute(url), getFit(fit), width, height, fadeDuration, errorHandler);
            break;
        }
      }
      else image = getByteImage(placeholderImage, getFit(fit), width, height, fadeDuration, null);
    }
    catch(e)
    {
      image = getByteImage(placeholderImage, getFit(fit), width, height, fadeDuration, null);
    }

    // return widget
    return image;
  }

  /// how the image will fit within the space it is given
  static BoxFit getFit(String? fit)
  {
    var boxFit = BoxFit.cover;

    if (S.isNullOrEmpty(fit)) return boxFit;
    fit = fit!.toLowerCase();

    switch (fit)
    {
      case 'cover':
        boxFit = BoxFit.cover;
        break;
      case 'fitheight':
      case 'height':
        boxFit = BoxFit.fitHeight;
        break;
      case 'fitwidth':
      case 'width':
        boxFit = BoxFit.fitWidth;
        break;
      case 'fill':
        boxFit = BoxFit.fill;
        break;
      case 'contain':
        boxFit = BoxFit.contain;
        break;
      case 'scaledown':
      case 'scale':
        boxFit = BoxFit.scaleDown;
        break;
      case 'none':
        boxFit = BoxFit.none;
        break;
      default:
        boxFit = BoxFit.cover;
    }
    return boxFit;
  }

  /// Apply a filter to the image
  static void applyFilter(Uint8List img, String filter)
  {
    IMAGE.Image? filtered = IMAGE.decodePng(img);
    switch(filter)
    {
      case 'sobel':
        IMAGE.sobel(filtered!, amount: 1.0);
        break;
      case 'quantize':
        IMAGE.quantize(filtered!, numberOfColors: 4);
        break;
      case 'remap':
        IMAGE.remapColors(filtered!,
            red: IMAGE.Channel.luminance,
            green: IMAGE.Channel.luminance,
            blue: IMAGE.Channel.luminance);
        break;
      case 'normalize':
        IMAGE.normalize(filtered!, 85, 170);
        break;
      case 'greyscale':
      case 'grayscale':
        IMAGE.grayscale(filtered!);
        break;
      case 'mirror':
        IMAGE.flipHorizontal(filtered!);
        break;
      case 'contrast':
        IMAGE.contrast(filtered, 200);
        break;
      case 'white':
        IMAGE.adjustColor(filtered!, whites: 130);
        break;
      case 'black':
        IMAGE.adjustColor(filtered!, blacks: 130);
        break;
      case 'mid':
        IMAGE.adjustColor(filtered!, mids: 130);
        break;
      case 'reverse':
        IMAGE.adjustColor(filtered!, blacks: 255, whites: 0);
        break;
      case 'convolution':
        IMAGE.convolution(filtered!, [0, -1, 0, -1, 5, -1, 0, -1, 0]);
        break;
      default:
        break;
    }
  }

  static dynamic getSvgImage(String url, BoxFit fit, double? width, double? height, dynamic errorBuilder)
  {
    return SvgPicture.network(url, fit: fit, width: width, height: height);
  }

  static dynamic getByteImage(Uint8List bytes, BoxFit fit, double? width, double? height, int? fadeDuration, dynamic errorBuilder)
  {
    return FadeInImage(
        placeholder: MemoryImage(placeholderImage),
        image: MemoryImage(bytes),
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: Duration(milliseconds: fadeDuration ?? 300),
        imageErrorBuilder: errorBuilder);
  }

  static dynamic getAssetImage(String? filename, BoxFit fit, double? width, double? height, int? fadeDuration, dynamic errorBuilder)
  {
    dynamic file;
    if (filename != null) file = System().getFile(filename);
    if (file == null) return MemoryImage(placeholderImage);

    return FadeInImage(
        placeholder: MemoryImage(placeholderImage),
        image: FileImage(file),
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: Duration(milliseconds: fadeDuration ?? 300),
        imageErrorBuilder: errorBuilder);
  }

  static dynamic getWebImage(String url, BoxFit fit, double? width, double? height, fadeDuration, dynamic errorBuilder)
  {
    return  FadeInImage.memoryNetwork(
        placeholder: placeholderImage,
        image: url,
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: Duration(milliseconds: fadeDuration ?? 300),
        imageErrorBuilder: errorBuilder);
  }
}

class _ImageViewState extends State<ImageView> implements IModelListener
{
  
  @override
  void initState()
  {
    super.initState();

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  
  @override
  void didUpdateWidget(ImageView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
      widget.model.minwidth  = constraints.minWidth;
      widget.model.maxwidth  = constraints.maxWidth;
      widget.model.minheight = constraints.minHeight;
      widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    String? url      = widget.model.url;
    double? opacity  = widget.model.opacity;
    double? width    = widget.model.width;
    double? height   = widget.model.height;
    String? fit      = widget.model.fit;
    String? filter   = widget.model.filter;
    Scope?  scope    = Scope.of(widget.model);
    // scoped file reference
    // if ((url != null) && (scope != null) && (scope.files.containsKey(url)))
    // {
    //   url = scope.files[url].uri;
    // }

    Widget view = ImageView.getImage(url, scope: scope, defaultvalue: widget.model.defaultvalue, width: width, height: height, fit: fit, filter: filter) ?? Container();

    // Flip
    if (widget.model.flip != null) {
      if (widget.model.flip!.toLowerCase() == 'vertical')
        // view = Transform(alignment: Alignment.center, transform: Matrix4.rotationX(pi), child: view);
        view = Transform.scale(scaleY: -1, child: view);
      if (widget.model.flip!.toLowerCase() == 'horizontal')
        // view = Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: view);
        view = Transform.scale(scaleX: -1, child: view);
    }

    // Alpha/Opacity
    if (opacity != null) view = Opacity(opacity: opacity, child: view);

    // Rotation
    if (widget.model.rotation != null)
      view = RotationTransition(turns: AlwaysStoppedAnimation(widget.model.rotation! / 360), child: view);

    // Stack Children
      if (widget.model.children != null && widget.model.children!.length > 0)
    view = Stack(children: [view]);

    // Interactive
    if (widget.model.interactive == true)
      view = InteractiveViewer(child: view);

    // constrained?
    if (widget.model.constrained)
    {
      Map<String,double?> constraints = widget.model.constraints;
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
          minHeight: constraints['minheight']!, maxHeight: constraints['maxheight']!,
          minWidth: constraints['minwidth']!, maxWidth: constraints['maxwidth']!));
    }

    return view;
  }
}