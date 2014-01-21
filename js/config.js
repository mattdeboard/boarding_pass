require.config({
    baseUrl: "/build",
    locale: "",
    paths: {
        jquery: '../bower_components/jquery/jquery.min',
        underscore: '../bower_components/underscore/underscore-min'
    },

    // shim: {
    //     underscore: {
    //         exports: '_'
    //     }
    // },

    packages: [
        {
            name: 'cs',
            location: '../bower_components/require-cs',
            main: 'cs'
        },
        {
            name: 'coffee-script',
            location: '../bower_components/coffee-script/extras',
            main: 'coffee-script'
        }
    ]
});
