// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_registration_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EventRegistrationState {
  bool get isRegistered => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of EventRegistrationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventRegistrationStateCopyWith<EventRegistrationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventRegistrationStateCopyWith<$Res> {
  factory $EventRegistrationStateCopyWith(
    EventRegistrationState value,
    $Res Function(EventRegistrationState) then,
  ) = _$EventRegistrationStateCopyWithImpl<$Res, EventRegistrationState>;
  @useResult
  $Res call({bool isRegistered, bool isLoading, String? errorMessage});
}

/// @nodoc
class _$EventRegistrationStateCopyWithImpl<
  $Res,
  $Val extends EventRegistrationState
>
    implements $EventRegistrationStateCopyWith<$Res> {
  _$EventRegistrationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventRegistrationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRegistered = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            isRegistered: null == isRegistered
                ? _value.isRegistered
                : isRegistered // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventRegistrationStateImplCopyWith<$Res>
    implements $EventRegistrationStateCopyWith<$Res> {
  factory _$$EventRegistrationStateImplCopyWith(
    _$EventRegistrationStateImpl value,
    $Res Function(_$EventRegistrationStateImpl) then,
  ) = __$$EventRegistrationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isRegistered, bool isLoading, String? errorMessage});
}

/// @nodoc
class __$$EventRegistrationStateImplCopyWithImpl<$Res>
    extends
        _$EventRegistrationStateCopyWithImpl<$Res, _$EventRegistrationStateImpl>
    implements _$$EventRegistrationStateImplCopyWith<$Res> {
  __$$EventRegistrationStateImplCopyWithImpl(
    _$EventRegistrationStateImpl _value,
    $Res Function(_$EventRegistrationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventRegistrationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRegistered = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$EventRegistrationStateImpl(
        isRegistered: null == isRegistered
            ? _value.isRegistered
            : isRegistered // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$EventRegistrationStateImpl implements _EventRegistrationState {
  const _$EventRegistrationStateImpl({
    this.isRegistered = false,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final bool isRegistered;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'EventRegistrationState(isRegistered: $isRegistered, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventRegistrationStateImpl &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isRegistered, isLoading, errorMessage);

  /// Create a copy of EventRegistrationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventRegistrationStateImplCopyWith<_$EventRegistrationStateImpl>
  get copyWith =>
      __$$EventRegistrationStateImplCopyWithImpl<_$EventRegistrationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _EventRegistrationState implements EventRegistrationState {
  const factory _EventRegistrationState({
    final bool isRegistered,
    final bool isLoading,
    final String? errorMessage,
  }) = _$EventRegistrationStateImpl;

  @override
  bool get isRegistered;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of EventRegistrationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventRegistrationStateImplCopyWith<_$EventRegistrationStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
