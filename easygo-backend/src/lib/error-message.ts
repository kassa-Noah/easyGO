import { ZodError, type ZodIssue } from "zod";

/**
 * The error message a person can actually read.
 *
 * Controllers answer with `message: error.message`, and for a validation
 * failure that was the stringified Zod issue array — an escaped JSON blob
 * shown verbatim in the app, starting with the registration form. The
 * individual messages inside it are written for people ("Password must
 * contain at least 6 characters"), so they are pulled out and joined
 * instead.
 *
 * Returns an empty string when there is nothing worth saying, so the
 * existing `messageOf(error) || "Unable to ..."` fallbacks keep working.
 */
export const messageOf = (error: unknown): string => {
  if (isZodError(error)) {
    const messages = error.issues
      .map(describe)
      .filter((message) => message.length > 0);

    // The same sentence can come from several fields; say it once.
    return [...new Set(messages)].join("; ");
  }

  if (error instanceof Error && error.message.trim().length > 0) {
    return error.message;
  }

  return "";
};

/**
 * One issue, as a sentence.
 *
 * Most schemas supply their own wording and it already names the field
 * ("First name is required"). The ones that fall back to Zod's default would
 * otherwise read "Invalid input: expected string, received undefined" with no
 * hint of which input, so the field is named in that case.
 */
const describe = (issue: ZodIssue): string => {
  const message = issue.message?.trim() ?? "";

  if (message.length === 0) {
    return "";
  }

  const label = labelOf(issue);

  if (label.length === 0) {
    return message;
  }

  const squash = (text: string) => text.toLowerCase().replace(/\s+/g, "");

  return squash(message).includes(squash(label))
    ? message
    : `${label}: ${message}`;
};

/** "firstName" and "first_name" both become "First name". */
const labelOf = (issue: ZodIssue): string => {
  const path = issue.path ?? [];
  const last = path[path.length - 1];

  if (last === undefined || last === null) {
    return "";
  }

  const words = String(last)
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/[_-]+/g, " ")
    .trim()
    .toLowerCase();

  return words.charAt(0).toUpperCase() + words.slice(1);
};

const isZodError = (error: unknown): error is ZodError => {
  return (
    error instanceof ZodError ||
    (typeof error === "object" &&
      error !== null &&
      Array.isArray((error as ZodError).issues))
  );
};
