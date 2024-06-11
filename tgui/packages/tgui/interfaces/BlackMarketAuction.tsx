import { useBackend } from '../backend';
import { Button, Flex, Section } from '../components';
import { Window } from '../layouts';

type Data = {};

export const BlackMarketUplink = (props) => {
  const { act, data } = useBackend<Data>();
  const { money } = data;
  return (
    <Window width={670} height={480} theme="hackerman">
      {/* No need for modals */}
      <Window.Content scrollable>
        Bingus
        <Flex direction="column">
          <Flex.Item width="45%" pr="5%">
            <Section>Box 1 (Show the product!)</Section>
            <Section>Bidding List (Show most recent few bids!)</Section>
          </Flex.Item>
          <Flex.Item width="50%">
            <Section>
              Show list of all upcoming auction items (Next 3, basically.)
            </Section>
            <Section>
              <Button>Reroll the auction block</Button>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
