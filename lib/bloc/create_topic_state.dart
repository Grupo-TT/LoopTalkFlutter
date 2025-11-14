part of 'create_topic_bloc.dart';

abstract class CreateTopicState extends Equatable {
  const CreateTopicState();

  @override
  List<Object> get props => [];
}

class CreateTopicInitial extends CreateTopicState {}

class CreateTopicInProgress extends CreateTopicState {}

class CreateTopicSuccess extends CreateTopicState {
  final Topico topico;

  const CreateTopicSuccess({required this.topico});

  @override
  List<Object> get props => [topico];
}

class CreateTopicFailure extends CreateTopicState {
  final String error;

  const CreateTopicFailure({required this.error});

  @override
  List<Object> get props => [error];
}
