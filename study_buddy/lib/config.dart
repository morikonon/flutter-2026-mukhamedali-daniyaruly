// Tunable numbers live here, so a change is a one-line edit.

/// Width at which the list turns into a grid.
const gridBreakpoint = 600.0;

/// A grid cell is never wider than this.
const maxCellWidth = 360.0;

/// The "N left" badge appears when this many seats or fewer remain.
const fewSeatsLeft = 5;

/// How long a session lasts; used by isPast and the countdown.
const sessionLength = Duration(minutes: 90);

const minSeats = 1;
const maxSeats = 500;

const minTitleLength = 3;
const maxTitleLength = 60;

const maxDescriptionLength = 300;
