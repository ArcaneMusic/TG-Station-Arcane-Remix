import { Icon, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { useState } from 'react';

export const AntagInfoCultist = (props) => {
  const { act, data } = useBackend();
  const { master_name } = data;
const [tab, setTab] = useState('spells');
  return (
    <Window width={400} height={400} theme="abductor">
      <Window.Content backgroundColor="#9d0032">
        <Icon
          size={20}
          name="ghost"
          color="#660020"
          position="absolute"
          top="20%"
          left="28%"
        />
        <Section fill>
          <Stack vertical fill textAlign="center">
            <Stack.Item fontSize="20px">
              Your mind has been flooded with the echoes of the forgotten god, Nar'Sie. You must enact their dark will and help them consume the light of this universe once more!
            </Stack.Item>
            <Stack.Item fontSize="30px">
              You are bound to the will of {master_name}!
            </Stack.Item>
            <Stack.Item fontSize="20px">
              Help them succeed in their goals at all costs.
            </Stack.Item>
          </Stack>
        </Section>
        <Section fill>
            <Tabs>
                <Tabs.Tab
                    icon="liquid-drop"
                    onClick={() => setTab('spells')}
                    selected={tab === 'spells'}
                >
                    Spells
                </Tabs.Tab>
                <Tabs.Tab
                    icon="sword"
                    onClick={() => setTab('tools')}
                    selected={tab === 'tools'}
                >
                    Tools
                </Tabs.Tab>
                <Tabs.Tab
                    icon="lightning"
                    onClick={() => setTab('quick-start')}
                    selected={tab === 'quick-start'}
                >
                    Quick-start
                </Tabs.Tab>
            </Tabs>
        </Section>
      </Window.Content>
    </Window>
  );
};


const TabInfo = (props) => {
  const { data } = useBackend<Data>();
  const { tab } = data;

  switch (tab) {
    case 'spells':
      return (
        <>
          <Stack.Item mb={1}>
            To assist your task, your program has been loaded with cutting edge{' '}
            <span style={textStyles.variable}>martial arts</span> skills.
          </Stack.Item>
          <Stack.Item grow>
            Ranged weaponry is <span style={textStyles.danger}>forbidden</span>.
            Ballistic defense is frowned upon. Style is paramount.
          </Stack.Item>
        </>
      );
    case 'tools':
      return (
        <>
          <Stack.Item mb={1}>
            You are an advanced combat unit. You have been outfitted with{' '}
            <span style={textStyles.variable}>lethal weaponry</span>.
          </Stack.Item>
          <Stack.Item grow>
            <span style={textStyles.danger}>Terminate</span> organic life at any
            cost.
          </Stack.Item>
        </>
      );
    case 'quickstart':
      return (
        <Stack.Item grow>
          <span style={{ ...textStyles.danger, fontSize: '16px' }}>
            ORGANIC LIFE MUST BE TERMINATED.
          </span>
        </Stack.Item>
      );
    default:
      return null;
  }
};
