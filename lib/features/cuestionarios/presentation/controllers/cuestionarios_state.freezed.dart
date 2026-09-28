// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cuestionarios_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CuestionariosState {

 CuestionariosStatus get status; List<Cuestionario> get cuestionarios; bool get saving; String? get errorMessage;
/// Create a copy of CuestionariosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CuestionariosStateCopyWith<CuestionariosState> get copyWith => _$CuestionariosStateCopyWithImpl<CuestionariosState>(this as CuestionariosState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CuestionariosState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.cuestionarios, cuestionarios)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(cuestionarios),saving,errorMessage);

@override
String toString() {
  return 'CuestionariosState(status: $status, cuestionarios: $cuestionarios, saving: $saving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $CuestionariosStateCopyWith<$Res>  {
  factory $CuestionariosStateCopyWith(CuestionariosState value, $Res Function(CuestionariosState) _then) = _$CuestionariosStateCopyWithImpl;
@useResult
$Res call({
 CuestionariosStatus status, List<Cuestionario> cuestionarios, bool saving, String? errorMessage
});




}
/// @nodoc
class _$CuestionariosStateCopyWithImpl<$Res>
    implements $CuestionariosStateCopyWith<$Res> {
  _$CuestionariosStateCopyWithImpl(this._self, this._then);

  final CuestionariosState _self;
  final $Res Function(CuestionariosState) _then;

/// Create a copy of CuestionariosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? cuestionarios = null,Object? saving = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CuestionariosStatus,cuestionarios: null == cuestionarios ? _self.cuestionarios : cuestionarios // ignore: cast_nullable_to_non_nullable
as List<Cuestionario>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CuestionariosState].
extension CuestionariosStatePatterns on CuestionariosState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CuestionariosState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CuestionariosState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CuestionariosState value)  $default,){
final _that = this;
switch (_that) {
case _CuestionariosState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CuestionariosState value)?  $default,){
final _that = this;
switch (_that) {
case _CuestionariosState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CuestionariosStatus status,  List<Cuestionario> cuestionarios,  bool saving,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CuestionariosState() when $default != null:
return $default(_that.status,_that.cuestionarios,_that.saving,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CuestionariosStatus status,  List<Cuestionario> cuestionarios,  bool saving,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _CuestionariosState():
return $default(_that.status,_that.cuestionarios,_that.saving,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CuestionariosStatus status,  List<Cuestionario> cuestionarios,  bool saving,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _CuestionariosState() when $default != null:
return $default(_that.status,_that.cuestionarios,_that.saving,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _CuestionariosState implements CuestionariosState {
  const _CuestionariosState({this.status = CuestionariosStatus.idle, final  List<Cuestionario> cuestionarios = const [], this.saving = false, this.errorMessage}): _cuestionarios = cuestionarios;
  

@override@JsonKey() final  CuestionariosStatus status;
 final  List<Cuestionario> _cuestionarios;
@override@JsonKey() List<Cuestionario> get cuestionarios {
  if (_cuestionarios is EqualUnmodifiableListView) return _cuestionarios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuestionarios);
}

@override@JsonKey() final  bool saving;
@override final  String? errorMessage;

/// Create a copy of CuestionariosState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CuestionariosStateCopyWith<_CuestionariosState> get copyWith => __$CuestionariosStateCopyWithImpl<_CuestionariosState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CuestionariosState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._cuestionarios, _cuestionarios)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_cuestionarios),saving,errorMessage);

@override
String toString() {
  return 'CuestionariosState(status: $status, cuestionarios: $cuestionarios, saving: $saving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$CuestionariosStateCopyWith<$Res> implements $CuestionariosStateCopyWith<$Res> {
  factory _$CuestionariosStateCopyWith(_CuestionariosState value, $Res Function(_CuestionariosState) _then) = __$CuestionariosStateCopyWithImpl;
@override @useResult
$Res call({
 CuestionariosStatus status, List<Cuestionario> cuestionarios, bool saving, String? errorMessage
});




}
/// @nodoc
class __$CuestionariosStateCopyWithImpl<$Res>
    implements _$CuestionariosStateCopyWith<$Res> {
  __$CuestionariosStateCopyWithImpl(this._self, this._then);

  final _CuestionariosState _self;
  final $Res Function(_CuestionariosState) _then;

/// Create a copy of CuestionariosState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? cuestionarios = null,Object? saving = null,Object? errorMessage = freezed,}) {
  return _then(_CuestionariosState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CuestionariosStatus,cuestionarios: null == cuestionarios ? _self._cuestionarios : cuestionarios // ignore: cast_nullable_to_non_nullable
as List<Cuestionario>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
