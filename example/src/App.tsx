import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  TextInput,
  Button,
  FlatList,
} from 'react-native';
import RNVideoZoomView,
{
  initSdk,
  joinMeeting,
  leaveCurrentMeeting,
  getParticipants,
  onEventListenerZoom,
  removeListenerZoom
} from 'react-native-video-zoom-sdk';

export default function App() {
  const [token, setToken] = React.useState('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfa2V5IjoiRlYxamZiQTlqNmpxMkdNRFJoRDBxVGJhQkEwQ25oV3lBblcwIiwidmVyc2lvbiI6MSwiaWF0IjoxNjIxMjQwMjA5LCJleHAiOjE2MjEyNTAyMDksInVzZXJfaWRlbnRpdHkiOiIxMjM0NTYiLCJ0cGMiOiJ0b3BpYyIsInB3ZCI6IjEyMzQ1NiJ9.cYKrFQDuMRAiYbrMpTnc1av16rxlN5d54RGrsIqPVLk');
  const [topic, setTopic] = React.useState('topic');
  const [sessionPassword, setSessionPassword] = React.useState('123456');
  const [userName, setUserName] = React.useState('');
  const [list, setList] = React.useState([]);
  const isSetup = React.useRef(false);

  React.useEffect(() => {
    if (isSetup.current === false) {
      isSetup.current = true;
      initSdk().then((success) => {
        console.log("init sdk ", success);
      });
      onEventListenerZoom((event) => {
        console.log('+++ event zoom ', event);
      })
    }
    return () => {
      removeListenerZoom();
    };
  }, []);

  const joinMeetingCallback = React.useCallback(() => {
    setList([]);
    joinMeeting({topic: topic, userName: userName, sessionPassword: sessionPassword, token: token});
  }, [topic, userName, sessionPassword, token]);

  const leaveMeeting = React.useCallback(() => {
    leaveCurrentMeeting();
  }, []);

  const getParticipantsCallback = React.useCallback(() => {
    getParticipants().then((members) => {
      console.log("list ", members);
      setList(members);
    });
  }, []);

  const renderItem = React.useCallback(({item, index}) => {
    return (
      <View style={{height: 80, width: 80, backgroundColor: 'blue'}}>
        <RNVideoZoomView userID={item.userID} style={{height: 80, width: 80}}/>
      </View>
    );
  }, []);

  return (
    <View style={styles.container}>
      <TextInput
        placeholder={'Token video zoom'}
        onChangeText={setToken}
        value={token}
        autoCapitalize={'none'}
        autoCorrect={false}
        autoCompleteType={'off'}
      />
      <TextInput
        placeholder={'Topic'}
        onChangeText={setTopic}
        value={topic}
        autoCapitalize={'none'}
        autoCorrect={false}
        autoCompleteType={'off'}
      />
      <TextInput
        placeholder={'Session password'}
        onChangeText={setSessionPassword}
        value={sessionPassword}
        autoCapitalize={'none'}
        autoCorrect={false}
        autoCompleteType={'off'}
      />
      <TextInput
        placeholder={'User name'}
        onChangeText={setUserName}
        value={userName}
        autoCapitalize={'none'}
        autoCorrect={false}
        autoCompleteType={'off'}
      />
      <Button
        onPress={joinMeetingCallback}
        title="Join meeting"
      />
      <Button
        onPress={leaveMeeting}
        title="Leave meeting"
      />
      <Button
        onPress={getParticipantsCallback}
        title="Get participants"
      />
      <FlatList
        horizontal={true}
        keyExtractor={(item, index) => item.userID}
        renderItem={renderItem}
        style={{height: 80, width: 400}}
        data={list}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
