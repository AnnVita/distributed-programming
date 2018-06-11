using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Frontend.Models;
using System.Net.Http;
using System.Net;

namespace Frontend.Controllers
{
    public class HomeController : Controller
    {
        private static string URL = "http://localhost:5003/api/values";
        private HttpClient httpClient = new HttpClient();
        
        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public IActionResult Upload()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Upload(string data)
        {
            if (data == null)
            {
                return Ok("");
            }
            List<KeyValuePair<string, string>> values = new List<KeyValuePair<string, string>>(){
                new KeyValuePair<string, string>("value", data),
            };
            var content = new FormUrlEncodedContent(values);
            var request = httpClient.PostAsync(URL, content);
            var requestContent = request.Result.Content.ReadAsStringAsync();
            return Ok(requestContent.Result);
        }

        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
