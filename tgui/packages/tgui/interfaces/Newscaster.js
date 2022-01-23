import { useBackend, useSharedState } from '../backend';
import { BlockQuote, Button, Collapsible, Flex, LabeledList, Section, Stack, Tabs, TextArea } from '../components';
import { Window } from '../layouts';

export const Newscaster = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    index,
    name = "Station Annoucements",
    description,
    icon,
  } = props;
  return (
    <Window
      width={575}
      height={420}>
      <Window.Content scrollable>
        <Flex mb={1}>
          <Flex.Item mr={1}>
            <NewscasterChannelSelector />
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <NewscasterInfobox />
            <NewscasterChannelBox />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const NewscasterButton = (props, context) => {
  const {
    index,
    name,
    description,
    icon,
  } = props;
  const { act, data } = useBackend(context);
  const [channelIndex, setChannelIndex] = useSharedState(context, 'channelIndex');
  const paid = data[`active_status_${index}`];
  return (
    <Stack
      align="baseline"
      wrap>
      <Stack.Item grow basis="content">
        <Button
          fluid
          icon={icon}
          selected={paid && channelIndex === index}
          tooltip={description}
          tooltipPosition="right"
          content={name}
        />
      </Stack.Item>
    </Stack>
  );
};

const NewscasterInfobox = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    user_name = "Joey Quiver",
    user_job = "Captain",
  } = data;
  return (
    <Section>
      <LabeledList title="Newscaster" minHeight="100%">
        <LabeledList.Item label="User">
          {user_name}
        </LabeledList.Item>
        <LabeledList.Item label="Occupation">
          {user_job}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const NewscasterChannelBox = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    channel_name = "Crab Shack",
    channel_owner = "Sleezy Adashi",
    channel_description = "This is my description box!",
  } = data;
  return (
    <Section title={channel_name} >
      <BlockQuote italic mb={1} ml={1} fontSize={1.2}>
        {channel_description}
      </BlockQuote>
      <LabeledList mt={1} mb={1}>
        <LabeledList.Item label="Owner">
          {channel_owner}
        </LabeledList.Item>
      </LabeledList>
      <Collapsible
        title="New Story"
        color="green"
        mt={1}>
        <Section>
          <TextArea
            fluid
            height={(window.innerHeight - 260) + "px"}
            backgroundColor="black"
            textColor="white"
            onChange={(e, value) => act('storyText', {
              bountytext: value,
            })} />
          <Button
            icon="print"
            content="Submit Story"
            onClick={() => act('createStory')}
            mt={1} />
        </Section>
      </Collapsible>
    </Section>
  );
};

const NewscasterChannelSelector = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    channels = [],
  } = data;
  return (
    <Section
      minHeight="100%"
      width={(window.innerWidth - 400) + "px"}>
      <Tabs vertical>
        {channels.map(channel => (
          <Tabs.Tab
            key={channel.name}
            selected={channel.name === activeChannelName}
            onClick={() => setActiveChannelName(channel.name)}>
            {channel.name}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};
