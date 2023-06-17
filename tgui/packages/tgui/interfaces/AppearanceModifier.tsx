import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  // whitelist: string[];
};

export const AppearanceModifier = (props, context) => {
  const { data } = useBackend<Data>(context);

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>Preview lives here</Stack.Item>
          <Stack.Item>Options lives here.</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
