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
	let trueUrl: URL;
	const originHeader = request.headers.get("origin");
	const refererHeader = request.headers.get("referer");

	if (originHeader) {
		trueUrl = new URL(originHeader);
	} else if (refererHeader) {
		trueUrl = new URL(refererHeader);
	} else {
		// Fallback for non-browser requests or missing headers
		const url = new URL(request.url);
		
		const forwardedHost = request.headers.get("x-forwarded-host")?.split(",")[0].trim();
		const forwardedProto = request.headers.get("x-forwarded-proto")?.split(",")[0].trim();
		const hostHeader = request.headers.get("host")?.split(",")[0].trim();

		const actualHost = forwardedHost || hostHeader || url.host;
		const actualProto = forwardedProto || url.protocol.replace(":", "");
		
		trueUrl = new URL(`${actualProto}://${actualHost}`);
	}

	return {
		rpName: siteName || trueUrl.hostname,
		rpId: trueUrl.hostname,
		origin: trueUrl.origin,
	};
}
