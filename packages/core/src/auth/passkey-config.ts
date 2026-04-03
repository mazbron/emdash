/**
 * Passkey configuration helper
 *
 * Extracts passkey configuration from the request URL.
 * This ensures the rpId and origin are correctly set for both
 * localhost development and production deployments.
 */

export interface PasskeyConfig {
	rpName: string;
	rpId: string;
	origin: string;
}

/**
 * Get passkey configuration from request
 *
 * @param request The request object
 * @param siteName Optional site name for rpName (defaults to hostname)
 */
export function getPasskeyConfig(request: Request, siteName?: string): PasskeyConfig {
	const url = new URL(request.url);

	const forwardedHost = request.headers.get("x-forwarded-host");
	const forwardedProto = request.headers.get("x-forwarded-proto");
	const hostHeader = request.headers.get("host");

	const actualHost = forwardedHost || hostHeader || url.host;
	const realHostname = actualHost.split(":")[0] || url.hostname;
	const actualProto = forwardedProto || url.protocol.replace(":", "");
	const origin = `${actualProto}://${actualHost}`;

	return {
		rpName: siteName || realHostname,
		rpId: realHostname,
		origin,
	};
}
