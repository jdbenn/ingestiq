import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

export async function health(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);


    return { status: 200 };
};

app.http('health', {
    methods: ['HEAD'],
    authLevel: 'anonymous',
    handler: health
});
