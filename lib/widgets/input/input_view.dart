// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/widgets/input/input_formatters.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_cvc_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_expiration_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class InputView extends StatefulWidget implements IWidgetView
{
  @override
  final InputModel model;
  final dynamic onChangeCallback;
  final dynamic onSubmitted;

  InputView(this.model, {this.onChangeCallback, this.onSubmitted}) : super(key: ObjectKey(model));

  @override
  State<InputView> createState() => _InputViewState();
}

class _InputViewState extends WidgetState<InputView> with WidgetsBindingObserver
{
  final focus = FocusNode();
  Timer? commitTimer;

  static const Map<String, TextInputAction> keyboardInputs = {
    'next': TextInputAction.next,
    'done': TextInputAction.done,
    'go': TextInputAction.go,
    'search': TextInputAction.search,
    'send': TextInputAction.send,
  };

  static const Map<String, TextInputType> keyboardTypes = {
    'text': TextInputType.text,
    'url': TextInputType.url,
    'name': TextInputType.name,
    'number': TextInputType.numberWithOptions(decimal: true),
    'numeric': TextInputType.numberWithOptions(decimal: true),
    'datetime': TextInputType.datetime,
    'date': TextInputType.datetime,
    'time': TextInputType.datetime,
    'emailaddress': TextInputType.emailAddress,
    'email': TextInputType.emailAddress,
    'password': TextInputType.visiblePassword,
    'phone': TextInputType.phone,
    'streetaddress': TextInputType.streetAddress,
    'address': TextInputType.streetAddress,
    'multiline': TextInputType.multiline,
    'none': TextInputType.none
  };

  @override
  void initState()
  {
    super.initState();

    // create the controller if its not already created in the model.
    // This allows us to get around having to use GlobalKey() on the Input to preserve the controller state
    widget.model.controller ??= TextEditingController();

    // set controller value
    widget.model.controller!.value = TextEditingValue(
        text: widget.model.value ?? "",
        selection: TextSelection.fromPosition(TextPosition(
            offset: widget.model.controller!.text.characters.length)));

    // On Loss of Focus
    focus.addListener(onFocusChange);

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();

    // debounce listener
    widget.model.controller!.addListener(_debounce);
  }

  @override
  void didUpdateWidget(InputView oldWidget)
  {
    super.didUpdateWidget(oldWidget);

    var oldcursorPos = widget.model.controller?.selection.base.offset;
    if (oldcursorPos != null)
    {
      widget.model.controller?.value = TextEditingValue(
          text: widget.model.value ?? "",
          selection: TextSelection.fromPosition(TextPosition(offset: oldcursorPos)));
    }
  }

  @override
  void dispose()
  {
    // cleanup the controller.
    // its important to set the controller to null so that it gets recreated
    // when the input rebuilds.
    focus.dispose();

    // Remove WidgetsBindingObserver mixin
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Callback to fire the [_InputViewState.build] when the [InputModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    // ensure we don't call setstate if the model update was entered via
    // keyboard by comparing the controller to the callback's value
    //return if not mounted
    if(!mounted) return;

    // grab the property that is changing
    if (model == this.model && property == Binding.toKey(this.model?.id, 'value'))
    {
      if (widget.model.controller?.text == value) return;

      // set the controllers value to the model value.
      // this acts in cases where the value changes based on an eval or set.
      widget.model.controller?.value = TextEditingValue(text: widget.model.value ?? "");
    }

    super.onModelChange(model);
  }

  @override
  void didChangeMetrics() {
    if (focus.hasFocus) {
      _ensureVisible();
    }
  }

  Future<void> _keyboardToggled() async {
    if (mounted) {
      EdgeInsets edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
    return;
  }

  Future<void> _ensureVisible() async {
    // Wait for the keyboard to come into view
    await Future.any(
        [Future.delayed(const Duration(milliseconds: 50)), _keyboardToggled()]);

    // No need to go any further if the node has not the focus
    if (!focus.hasFocus) {
      return;
    }

    // Find the object which has the focus
    RenderAbstractViewport? viewport;
    RenderObject? object;
    try {
      object = context.findRenderObject();
      if (object is RenderObject) viewport = RenderAbstractViewport.of(object);
    } catch (e) {
      viewport = null;
    }
    // If we are not working in a Scrollable, skip this routine
    if (viewport == null) return;

    // Get the Scrollable state (in order to retrieve its offset)
    ScrollableState scrollableState = Scrollable.of(context);

    // Get its offset
    ScrollPosition position = scrollableState.position;
    double alignment;

    if (position.pixels > viewport.getOffsetToReveal(object!, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 1.0;
    } else if (position.pixels <
        (viewport.getOffsetToReveal(object, 1.0).offset +
            MediaQuery.of(context).viewInsets.bottom)) {
      // Move up to the bottom of the viewport
      alignment = 0.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }

    position.ensureVisible(
      object,
      alignment: alignment,
      duration: Duration(milliseconds: 100),
      curve: Curves.linearToEaseOut,
    );
  }

  void _handleOnChange(String value)
  {
    if (widget.model.editable == false)
    {
      widget.model.controller?.value = TextEditingValue(text: widget.model.value);
      return;
    }
  }

  void _handleSubmit(String _) {
    try {
      if (isNullOrEmpty(widget.model.keyboardInput) ||
          widget.model.keyboardInput!.toLowerCase() == 'done' ||
          widget.model.keyboardInput!.toLowerCase() == 'go' ||
          widget.model.keyboardInput!.toLowerCase() == 'search' ||
          widget.model.keyboardInput!.toLowerCase() == 'send') {
        focus.unfocus();
        return;
      } else if (widget.model.keyboardInput!.toLowerCase() == 'next') {
        try {
          FocusScope.of(context).nextFocus();
        } catch (e) {
          focus.unfocus();
        }
        return;
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

  String validate(String text) {
    return 'field must be supplied';
  }

  onFocusChange() async
  {
    var editable = (widget.model.editable != false);
    if (!editable) return;

    // commit changes on loss of focus
    if (!focus.hasFocus)
    {
      // cancel the debounce timer
      if (commitTimer?.isActive ?? false) commitTimer!.cancel();

      // trigger onFocusLost event
      bool ok = await widget.model.onFocusLost(context);

      // commit
      if (ok) await _commit();
    }
  }

  Future<bool> _commit() async
  {
    String? value = widget.model.controller?.text;

    // value changed?
    if (widget.model.value != value)
    {
      // set answer
      await widget.model.answer(value);

      // fire the onChange event
      await widget.model.onChange(context);
    }

    return true;
  }

  // triggers when data is typed
  void _debounce()
  {
    // this should only trigger with the oninputchange
    if (commitTimer?.isActive ?? false) commitTimer!.cancel();

    // reset the timer
    commitTimer = Timer(Duration(milliseconds: 1000), () async => _commit());
  }

  void onClear()
  {
    if (widget.onChangeCallback != null)
    {
      widget.onChangeCallback(widget.model, '');
    }

    widget.model.controller!.text = '';
    _commit();
  }

  List<TextInputFormatter> _getFormatters()
  {
    List<TextInputFormatter> formatters = [];

    // capitalization
    if (widget.model.capitalization == CapitalizationTypes.upper)
    {
      formatters.add(UpperCaseTextFormatter());
    }

    if (widget.model.capitalization == CapitalizationTypes.lower)
    {
      formatters.add(LowerCaseTextFormatter());
    }

    if (widget.model.length != null)
    {
      formatters.add(LengthLimitingTextInputFormatter(widget.model.length));
    }

    // format type
    switch (widget.model.formatType)
    {
      // not 100% sure what the purpose of the first 3 formatters are.
      case 'numeric':
        formatters.add(TextToNumericFormatter());
        break;

      case 'int':
        formatters.add(TextToIntegerFormatter());
        break;

      case 'bool':
        formatters.add(TextToBooleanFormatter());
        break;

      case 'credit':
        formatters.add(CreditCardNumberInputFormatter());
        break;

      case 'cvc':
        formatters.add(CreditCardCvcInputFormatter());
        break;

      case 'expire':
        formatters.add(CreditCardExpirationDateFormatter());
        break;

      case 'currency':
        formatters.add(CurrencyInputFormatter());
        break;

      case 'phone':
        formatters.add(PhoneInputFormatter());
        break;

      default:
        break;
    }

    //using allow must not use a mask for filteringtextformatter, causes issues.
    if (widget.model.allow != null && widget.model.mask == null)
    {
      // Not sure how to make this work with interpolation
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[' "${widget.model.allow!}" ']')));
    }

    if (widget.model.deny != null)
    {
      // Not sure how to make this work with interpolation
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'[' "${widget.model.deny!}" ']')));
    }

    // The mask formatter with allow
    if (widget.model.mask != null)
    {
      if (widget.model.allow != null)
      {
        formatters.add(MaskedInputFormatter(widget.model.mask, allowedCharMatcher: RegExp(r'[' "${widget.model.allow!}" ']+')));
      }
      else
      {
        formatters.add(MaskedInputFormatter(widget.model.mask));
      }
    }

    return formatters;
  }

  TextInputType _getKeyboardType()
  {
    var keyboardType = widget.model.keyboardType?.trim().toLowerCase();

    // keyboard based on format type
    switch (widget.model.formatType)
    {
      case 'expire':
      case 'int':
      case 'credit':
      case 'cvc':
      case 'numeric':
      case 'currency':
        keyboardType = "numeric";
        break;

      case 'phone':
        keyboardType = "phone";
        break;

      case 'password':
        keyboardType = "password";
        break;

      case 'email':
        keyboardType = "email";
        break;

      default:
        break;
    }

    var inputType = TextInputType.text;
    if (keyboardType != null && keyboardTypes.containsKey(keyboardType)) inputType = keyboardTypes[keyboardType]!;
    return inputType;
  }

  _getBorder(Color mainColor, Color? secondaryColor)
  {
    secondaryColor ??= mainColor;

    if(widget.model.border == "none")
    {
      return OutlineInputBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide: BorderSide(
            color: Colors.transparent,
            width: 2),
      );
    }
        else if (widget.model.border == "bottom" ||
        widget.model.border == "underline"){
        return UnderlineInputBorder(
      borderRadius: BorderRadius.all(
          Radius.circular(0)),
      borderSide: BorderSide(
          color: widget.model.editable == false
              ? secondaryColor
              : mainColor,
          width: widget.model.borderwidth),
    );}

    else {
      return OutlineInputBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide: BorderSide(
            color: mainColor,
            width: widget.model.borderwidth),
      );
    }

  }

  _getSuffixIcon(Color hintTextColor)
  {
    if (widget.model.formatType == "password" && widget.model.clear == false)
    {
      return IconButton(icon: Icon(widget.model.obscure ? Icons.visibility : Icons.visibility_off, size: 17, color: hintTextColor),
        onPressed: () => widget.model.obscure = !widget.model.obscure,
      );
    }
    else if (widget.model.enabled != false && widget.model.editable != false && widget.model.clear)
    {
      return IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.clear_rounded, size: 17, color: hintTextColor),
        onPressed: () {
          onClear();
        },
      );
    }
    else
    {
      return null;
    }
  }

  InputDecoration _getDecoration()
  {
    // set the border colors
    Color? enabledBorderColor = widget.model.bordercolor ?? Theme.of(context).colorScheme.outline;
    Color? disabledBorderColor = Theme.of(context).disabledColor;
    Color? focusBorderColor = Theme.of(context).focusColor;
    Color? errorBorderColor = Theme.of(context).colorScheme.error;

    String? hint = widget.model.hint;
    Color? hintTextColor = widget.model.textcolor?.withOpacity(0.7) ?? Theme.of(context).colorScheme.onSurfaceVariant;
    Color? errorTextColor = Theme.of(context).colorScheme.error;

    double additionalTopPad = widget.model.border == "bottom" || widget.model.border == "underline" ? 3 : 15;
    double additionalBottomPad = widget.model.border == "bottom" || widget.model.border == "underline" ? 14 : 15;

    double? fontsize = widget.model.size;

    var decoration = InputDecoration(
      isDense: false,
      errorMaxLines: 8,
      hintMaxLines: 8,
      fillColor: widget.model.getFieldColor(context),
      filled: true,
      contentPadding: widget.model.dense == true
          ? EdgeInsets.only(
          left: 6, top: 0, right: 6, bottom: 0)
          : EdgeInsets.only(
          left: 10, top: additionalTopPad, right: 10, bottom: additionalBottomPad),
      alignLabelWithHint: true,
      labelText: widget.model.dense ? null : hint,
      labelStyle: TextStyle(
        fontSize: fontsize != null ? fontsize - 2 : 14,
        color: widget.model.getErrorHintColor(context, color: hintTextColor),
        shadows: <Shadow>[
          Shadow(
              offset: Offset(0.0, 0.5),
              blurRadius: 2.0,
              color: widget.model.color ?? Colors.transparent
          ),
          Shadow(
              offset: Offset(0.0, 0.5),
              blurRadius: 2.0,
              color: widget.model.color ?? Colors.transparent
          ),
          Shadow(
              offset: Offset(0.0, 0.5),
              blurRadius: 2.0,
              color: widget.model.color ?? Colors.transparent
          ),
        ],
      ),
      errorStyle: TextStyle(
        fontSize: fontsize ?? 14,
        fontWeight: FontWeight.w300,
        color: errorTextColor,
      ),
      errorText: widget.model.alarmText,
      hintText: widget.model.dense ? hint : null,
      hintStyle: TextStyle(
        fontSize: fontsize ?? 14,
        fontWeight: FontWeight.w300,
        color: widget.model.getErrorHintColor(context, color: hintTextColor),
      ),


      counterText: "",
      // widget.model.error is getting set to null somewhere.

      //Icon Attributes
      prefixIcon: widget.model.icon != null ? Padding(
          padding: EdgeInsets.only(
              right: 10,
              left: 10,
              bottom: 0),
          child: Icon(widget.model.icon)) : null,
      prefixIconConstraints: BoxConstraints(maxHeight: 24),
      suffixIcon: _getSuffixIcon(hintTextColor),
      suffixIconConstraints: (widget.model.enabled != false &&
          widget.model.editable != false &&
          widget.model.clear)
          ? BoxConstraints(maxHeight: 20)
          : null,

      //border attributes
      border: _getBorder(enabledBorderColor, null),
      errorBorder: _getBorder(errorBorderColor, null),
      focusedErrorBorder: _getBorder(errorBorderColor, null),
      focusedBorder: _getBorder(focusBorderColor, null),
      enabledBorder: _getBorder(enabledBorderColor, null),
      disabledBorder: _getBorder(disabledBorderColor, enabledBorderColor),
    );

    return decoration;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set the text color arrays
    Color? enabledTextColor = widget.model.textcolor;
    Color? disabledTextColor = Theme.of(context).disabledColor;

    double? fontsize = widget.model.size;
    int? length = widget.model.length;
    int? lines = widget.model.lines;

    if (widget.model.obscure) lines = 1;

    // get formatters
    var formatters = _getFormatters();

    // get keyboard type
    var keyboard = _getKeyboardType();

    var action = (widget.model.keyboardInput != null)
        ? (keyboardInputs[widget.model.keyboardInput?.toLowerCase()] ??
        TextInputAction.next)
        : TextInputAction.next;

    var style = TextStyle(
        color: widget.model.enabled != false
            ? enabledTextColor ?? Theme.of(context).colorScheme.onBackground
            : disabledTextColor,
        fontSize: fontsize);

    var minLines = widget.model.expand == true ? null : lines ?? 1;
    var maxLines = widget.model.expand == true ? null : widget.model.obscure ? 1 : widget.model.maxlines ?? (widget.model.wrap == true ? null : lines ?? 1);

    Widget view = TextField(
        controller: widget.model.controller,
        focusNode: focus,
        autofocus: false,
        autocorrect: false,
        expands: widget.model.expand,
        obscureText: widget.model.obscure,
        keyboardType: keyboard,
        textInputAction: action,
        inputFormatters: formatters,
        enabled: (widget.model.enabled == false) ? false : true,
        style: style,
        textAlignVertical: widget.model.expand ? TextAlignVertical.top : TextAlignVertical.center,
        maxLength: length,
        maxLines: maxLines,
        minLines: minLines,
        maxLengthEnforcement: length != null ? MaxLengthEnforcement.enforced : MaxLengthEnforcement.none,
        decoration: _getDecoration(),
        onChanged: _handleOnChange,
        onSubmitted: _handleSubmit);

    if (widget.model.dense) view = Padding(padding: EdgeInsets.all(4), child: view);

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width = 800;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    return view;
  }
}
