// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preguntas_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreguntasState {

 PreguntasStatus get status; String get cuestionarioId; List<Pregunta> get preguntas; bool get saving; String? get errorMessage;
/// Create a copy of PreguntasState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreguntasStateCopyWith<PreguntasState> get copyWith => _$PreguntasStateCopyWithImpl<PreguntasState>(this as PreguntasState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreguntasState&&(identical(other.status, status) || other.status == status)&&(identical(other.cuestionarioId, cuestionarioId) || other.cuestionarioId == cuestionarioId)&&const DeepCollectionEquality().equals(other.preguntas, preguntas)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,cuestionarioId,const DeepCollectionEquality().hash(preguntas),saving,errorMessage);

@override
String toString() {
  return 'PreguntasState(status: $status, cuestionarioId: $cuestionarioId, preguntas: $preguntas, saving: $saving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PreguntasStateCopyWith<$Res>  {
  factory $PreguntasStateCopyWith(PreguntasState value, $Res Function(PreguntasState) _then) = _$PreguntasStateCopyWithImpl;
@useResult
$Res call({
 PreguntasStatus status, String cuestionarioId, List<Pregunta> preguntas, bool saving, String? errorMessage
});




}
/// @nodoc
class _$PreguntasStateCopyWithImpl<$Res>
    implements $PreguntasStateCopyWith<$Res> {
  _$PreguntasStateCopyWithImpl(this._self, this._then);

  final PreguntasState _self;
  final $Res Function(PreguntasState) _then;

/// Create a copy of PreguntasState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? cuestionarioId = null,Object? preguntas = null,Object? saving = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PreguntasStatus,cuestionarioId: null == cuestionarioId ? _self.cuestionarioId : cuestionarioId // ignore: cast_nullable_to_non_nullable
as String,preguntas: null == preguntas ? _self.preguntas : preguntas // ignore: cast_nullable_to_non_nullable
as List<Pregunta>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PreguntasState].
extension PreguntasStatePatterns on PreguntasState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreguntasState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreguntasState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreguntasState value)  $default,){
final _that = this;
switch (_that) {
case _PreguntasState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreguntasState value)?  $default,){
final _that = this;
switch (_that) {
case _PreguntasState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PreguntasStatus status,  String cuestionarioId,  List<Pregunta> preguntas,  bool saving,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreguntasState() when $default != null:
return $default(_that.status,_that.cuestionarioId,_that.preguntas,_that.saving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PreguntasStatus status,  String cuestionarioId,  List<Pregunta> preguntas,  bool saving,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PreguntasState():
return $default(_that.status,_that.cuestionarioId,_that.preguntas,_that.saving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PreguntasStatus status,  String cuestionarioId,  List<Pregunta> preguntas,  bool saving,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PreguntasState() when $default != null:
return $default(_that.status,_that.cuestionarioId,_that.preguntas,_that.saving,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PreguntasState implements PreguntasState {
  const _PreguntasState({this.status = PreguntasStatus.idle, this.cuestionarioId = '', final  List<Pregunta> preguntas = const [], this.saving = false, this.errorMessage}): _preguntas = preguntas;
  

@override@JsonKey() final  PreguntasStatus status;
@override@JsonKey() final  String cuestionarioId;
 final  List<Pregunta> _preguntas;
@override@JsonKey() List<Pregunta> get preguntas {
  if (_preguntas is EqualUnmodifiableListView) return _preguntas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preguntas);
}

@override@JsonKey() final  bool saving;
@override final  String? errorMessage;

/// Create a copy of PreguntasState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreguntasStateCopyWith<_PreguntasState> get copyWith => __$PreguntasStateCopyWithImpl<_PreguntasState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreguntasState&&(identical(other.status, status) || other.status == status)&&(identical(other.cuestionarioId, cuestionarioId) || other.cuestionarioId == cuestionarioId)&&const DeepCollectionEquality().equals(other._preguntas, _preguntas)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,cuestionarioId,const DeepCollectionEquality().hash(_preguntas),saving,errorMessage);

@override
String toString() {
  return 'PreguntasState(status: $status, cuestionarioId: $cuestionarioId, preguntas: $preguntas, saving: $saving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PreguntasStateCopyWith<$Res> implements $PreguntasStateCopyWith<$Res> {
  factory _$PreguntasStateCopyWith(_PreguntasState value, $Res Function(_PreguntasState) _then) = __$PreguntasStateCopyWithImpl;
@override @useResult
$Res call({
 PreguntasStatus status, String cuestionarioId, List<Pregunta> preguntas, bool saving, String? errorMessage
});




}
/// @nodoc
class __$PreguntasStateCopyWithImpl<$Res>
    implements _$PreguntasStateCopyWith<$Res> {
  __$PreguntasStateCopyWithImpl(this._self, this._then);

  final _PreguntasState _self;
  final $Res Function(_PreguntasState) _then;

/// Create a copy of PreguntasState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? cuestionarioId = null,Object? preguntas = null,Object? saving = null,Object? errorMessage = freezed,}) {
  return _then(_PreguntasState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PreguntasStatus,cuestionarioId: null == cuestionarioId ? _self.cuestionarioId : cuestionarioId // ignore: cast_nullable_to_non_nullable
as String,preguntas: null == preguntas ? _self._preguntas : preguntas // ignore: cast_nullable_to_non_nullable
as List<Pregunta>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
