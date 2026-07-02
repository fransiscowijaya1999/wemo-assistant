import { createTheme, type MantineColorsTuple } from '@mantine/core';

// "wemo" — warm workshop amber. Shades follow Mantine's validated orange scale so
// filled/light/outline contrast stays correct in both color schemes; red remains
// reserved for destructive actions.
const wemo: MantineColorsTuple = [
  '#fff4e6',
  '#ffe8cc',
  '#ffd8a8',
  '#ffc078',
  '#ffa94d',
  '#ff922b',
  '#fd7e14',
  '#f76707',
  '#e8590c',
  '#d9480f',
];

export const theme = createTheme({
  colors: { wemo },
  primaryColor: 'wemo',
  primaryShade: { light: 7, dark: 6 },
  defaultRadius: 'md',
  headings: { fontWeight: '650' },
});
